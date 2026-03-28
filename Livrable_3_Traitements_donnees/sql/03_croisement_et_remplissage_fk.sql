-- ============================================================
-- 03_enrichissement_fk.sql
-- Objectif :
--  - Enrichir / remplir des clés étrangères (FK) après création des tables finales
--  - Standardiser province / ccaa (clé + libellé std)
--  - Extraire place_lat / place_lon depuis place.coordonnees
--  - Remplir weather_station.place_id (matching + patches)
--  - Remplir bird_detection.place_id (nearest place) SANS PostGIS
--    avec SEUIL distance : 2° (dist2 < 4) pour éviter les rattachements absurdes
--  - Option : fournir une estimation "km" (approx) dans les vues (script 04)
-- ============================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS unaccent;

SET search_path TO CREC, public;

-- ============================================================
-- 0) place_lat / place_lon depuis coordonnees (relançable)
-- ============================================================

ALTER TABLE crec.place ADD COLUMN IF NOT EXISTS place_lon DOUBLE PRECISION;
ALTER TABLE crec.place ADD COLUMN IF NOT EXISTS place_lat DOUBLE PRECISION;

UPDATE crec.place
SET
  place_lon = (regexp_match(coordonnees,'Point\(([-0-9\.]+)\s+([-0-9\.]+)\)'))[1]::DOUBLE PRECISION,
  place_lat = (regexp_match(coordonnees,'Point\(([-0-9\.]+)\s+([-0-9\.]+)\)'))[2]::DOUBLE PRECISION
WHERE coordonnees IS NOT NULL
  AND (place_lon IS NULL OR place_lat IS NULL);

CREATE INDEX IF NOT EXISTS ix_place_lat_lon
ON crec.place (place_lat, place_lon);

-- ============================================================
-- 0bis) Standardisation PROVINCE / CCAA (relançable)
-- ============================================================

ALTER TABLE crec.place
  ADD COLUMN IF NOT EXISTS province_key TEXT,
  ADD COLUMN IF NOT EXISTS ccaa_key TEXT,
  ADD COLUMN IF NOT EXISTS province_std TEXT,
  ADD COLUMN IF NOT EXISTS ccaa_std TEXT;

-- Génère des "keys" propres (uppercase, unaccent, espaces normalisés)
-- + supprime préfixes type "Provincia de ..."
UPDATE crec.place
SET
  province_key = NULLIF(
    upper(
      regexp_replace(
        regexp_replace(
          unaccent(btrim(coalesce(province_label, ''))),
          '^(PROVINCIA\s+DE\s+|PROVINCIA\s+DEL\s+|PROVINCIA\s+DELA\s+|PROVINCE\s+DE\s+|PROVINCE\s+DU\s+)',
          '',
          'i'
        ),
        '\s+',
        ' ',
        'g'
      )
    ),
    ''
  ),
  ccaa_key = NULLIF(
    upper(
      regexp_replace(
        unaccent(btrim(coalesce(ccaa_label, ''))),
        '\s+',
        ' ',
        'g'
      )
    ),
    ''
  )
WHERE province_key IS NULL
   OR ccaa_key IS NULL
   OR province_std IS NULL
   OR ccaa_std IS NULL;

-- Tables de référence (permet de corriger proprement sans DBeaver)
CREATE TABLE IF NOT EXISTS crec.ref_province (
  province_key TEXT PRIMARY KEY,
  province_std TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS crec.ref_ccaa (
  ccaa_key TEXT PRIMARY KEY,
  ccaa_std TEXT NOT NULL
);

-- Remplissage par défaut (label “joli”)
INSERT INTO crec.ref_province (province_key, province_std)
SELECT DISTINCT
  province_key,
  initcap(lower(province_key))
FROM crec.place
WHERE province_key IS NOT NULL
ON CONFLICT (province_key) DO NOTHING;

INSERT INTO crec.ref_ccaa (ccaa_key, ccaa_std)
SELECT DISTINCT
  ccaa_key,
  initcap(lower(ccaa_key))
FROM crec.place
WHERE ccaa_key IS NOT NULL
ON CONFLICT (ccaa_key) DO NOTHING;

-- Patches AUTOMATIQUES fréquents (cohérence multi-format)
-- (tu peux en ajouter autant que tu veux ici)
UPDATE crec.ref_ccaa
SET ccaa_std = 'Andalucía'
WHERE ccaa_key IN ('ANDALUCIA','ANDALOUSIE');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Castilla-La Mancha'
WHERE ccaa_key IN ('CASTILLALAMANCHA','CASTILLE LA MANCHE','CASTILLA LA MANCHA');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Castilla y León'
WHERE ccaa_key IN ('CASTILLA Y LEON','CASTILLE ET LEON','CASTILLE ET LÉON');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Comunidad Valenciana'
WHERE ccaa_key IN ('COMUNIDAD VALENCIANA','VALENCE');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Cataluña'
WHERE ccaa_key IN ('CATALUNA','CATALOGNE');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Extremadura'
WHERE ccaa_key IN ('ESTREMADURE','EXTREMADURA');

UPDATE crec.ref_ccaa
SET ccaa_std = 'Canarias'
WHERE ccaa_key IN ('CANARIAS','CANARY ISLANDS');

-- Provinces : suppression du préfixe "Provincia De X" déjà gérée par regexp,
-- mais il reste parfois des versions "PROVINCIA DE CADIZ" etc.
UPDATE crec.ref_province
SET province_std = initcap(lower(province_key))
WHERE province_key LIKE 'PROVINCIA %';

-- Application des libellés std à place
UPDATE crec.place p
SET province_std = r.province_std
FROM crec.ref_province r
WHERE p.province_key = r.province_key;

UPDATE crec.place p
SET ccaa_std = r.ccaa_std
FROM crec.ref_ccaa r
WHERE p.ccaa_key = r.ccaa_key;

CREATE INDEX IF NOT EXISTS ix_place_province_std
ON crec.place (province_std);

CREATE INDEX IF NOT EXISTS ix_place_ccaa_std
ON crec.place (ccaa_std);

-- ============================================================
-- 1) weather_station.place_id (matching + patches)
-- ============================================================

-- Matching exact nom station == place.space_label (sans accents/casse)
UPDATE crec.weather_station ws
SET place_id = p.place_id
FROM crec.place p
WHERE ws.place_id IS NULL
  AND ws.name IS NOT NULL
  AND p.space_label IS NOT NULL
  AND upper(unaccent(btrim(ws.name))) = upper(unaccent(btrim(p.space_label)))
  AND (p.type_label ILIKE 'city%' OR p.type_label IS NULL);

-- Matching “début de chaîne” (ex: "JEREZ AEROPUERTO" -> "Jerez")
UPDATE crec.weather_station ws
SET place_id = p.place_id
FROM crec.place p
WHERE ws.place_id IS NULL
  AND ws.name IS NOT NULL
  AND p.space_label IS NOT NULL
  AND (p.type_label ILIKE 'city%' OR p.type_label IS NULL)
  AND upper(unaccent(btrim(ws.name))) LIKE upper(unaccent(btrim(p.space_label))) || '%';

-- Patch spécifique MASPALOMAS
UPDATE crec.weather_station ws
SET place_id = p.place_id
FROM crec.place p
WHERE ws.station_code = 'C689E'
  AND p.wikidata_id = 'Q580743';

-- ============================================================
-- 2) bird_detection.place_id : annuler d’abord les affectations trop lointaines
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_bird_detection_place_id
ON crec.bird_detection (place_id);

UPDATE crec.bird_detection bd
SET place_id = NULL
FROM crec.place p
WHERE bd.place_id = p.place_id
  AND bd.coordinate IS NOT NULL
  AND bd.coordinate[1] IS NOT NULL
  AND bd.coordinate[2] IS NOT NULL
  AND p.place_lat IS NOT NULL
  AND p.place_lon IS NOT NULL
  AND (
    ((p.place_lat - bd.coordinate[1]) * (p.place_lat - bd.coordinate[1])
   + (p.place_lon - bd.coordinate[2]) * (p.place_lon - bd.coordinate[2])) > 4
  );

-- ============================================================
-- 3) Recalcul nearest pour les NULL (bbox + seuil)
-- ============================================================

WITH nearest_place AS (
  SELECT
    bd.detection_id,
    np.place_id
  FROM crec.bird_detection bd
  JOIN LATERAL (
    SELECT
      p.place_id,
      ((p.place_lat - bd.coordinate[1]) * (p.place_lat - bd.coordinate[1])
     + (p.place_lon - bd.coordinate[2]) * (p.place_lon - bd.coordinate[2])) AS dist2
    FROM crec.place p
    WHERE p.place_lat IS NOT NULL
      AND p.place_lon IS NOT NULL
      AND bd.coordinate IS NOT NULL
      AND bd.coordinate[1] IS NOT NULL
      AND bd.coordinate[2] IS NOT NULL
      AND p.place_lat BETWEEN (bd.coordinate[1] - 0.30) AND (bd.coordinate[1] + 0.30)
      AND p.place_lon BETWEEN (bd.coordinate[2] - 0.30) AND (bd.coordinate[2] + 0.30)
    ORDER BY dist2 ASC
    LIMIT 1
  ) np ON TRUE
  WHERE bd.place_id IS NULL
    AND np.dist2 < 4
)
UPDATE crec.bird_detection bd
SET place_id = n.place_id
FROM nearest_place n
WHERE bd.detection_id = n.detection_id;

-- ============================================================
-- 4) Vérifications
-- ============================================================

-- Couverture stations météo : combien ont un place_id ?
SELECT
  COUNT(*) AS weather_station_total,
  COUNT(place_id) AS weather_station_with_place_id,
  ROUND(100.0 * COUNT(place_id) / NULLIF(COUNT(*),0), 2) AS pct
FROM weather_station;

-- Couverture bird_detection : combien ont un place_id ?
SELECT
  COUNT(*) AS bird_detection_total,
  COUNT(place_id) AS bird_detection_with_place_id,
  ROUND(100.0 * COUNT(place_id) / NULLIF(COUNT(*),0), 2) AS pct
FROM bird_detection;

COMMIT;