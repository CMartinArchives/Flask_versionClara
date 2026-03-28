# Application Flask — Lancer le serveur en local

## 1. Cloner le dépôt

```bash
git clone https://github.com/CMartinArchives/Flask_versionClara.git
cd Flask_versionClara
```

---

## 2. Créer un environnement virtuel

```bash
python3 -m venv env
source env/bin/activate
```

---

## 3. Installer les dépendances de l'application

```bash
pip install -r requirements.txt
```

---
## 4. Installations pour visualiser la carte interactive en javascript

Télécharger et installer Node.js (version LTS) à l'adresse https://nodejs.org/fr/download et télécharger la version LTS

```node
# Télécharger et installer nvm :
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# au lieu de redémarrer le shell
\. "$HOME/.nvm/nvm.sh"

# Télécharger et installer Node.js :
nvm install 24

# Vérifiez la version de Node.js :
node -v # Doit afficher "v24.14.1".

# Vérifier la version de npm :
npm -v # Doit afficher "11.11.0".
```

Vérifier l'installation

```
node --version
npm --version
```

Initialiser npm dans le projet (veiller à être dans le dossier du projet)

```
npm init -y
```
Installer Leaflet

```
npm install leaflet
```

Les fichiers Leaflet leaflet.css, leaflet.js et les images associées contenues dans node_modules/leaflet/dist doivent être placés dans le dossier static de l'application (dans ce git ces fichiers sont dors et déjà au bon emplacement).

## 5. Générrer le fichier GeoJSON
La carte interactive utilise les données sur le faucons contenues dans le fichier donnees.csv, données converties au format json (fichier data_js.json) par le script csv_to_geojson.py.

Pour obtenir le fichier data_js.json par l'exécution du script csv_to_geojson.py :

```script csv to json
python csv_to_geojson.py
```
Dans ce dépôt git le fichier data_js.json est déjà prêt à l'emploi

## 6. Configurer les variables d’environnement

Transformer le fichier envexample en fichier .env à la racine du projet (ne pas oublier de préciser son mot de passe) :

```env
DEBUG=True

DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=crec

SECRET_KEY=dev
```

---

## 7. Vérifier que la base PostgreSQL existe

La base utilisée est :

**crec**

Les tables principales du projet sont :

- `crec.falcon`
- `crec.bird_detection`
- `crec.place`
- `crec.weather_station`
- `crec.weather_measurement`
- `crec.user_account`
- `crec.comment`

Si nécessaire, créer les tables utilisateurs et commentaires :

```sql
CREATE TABLE crec.user_account (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT
);
```

```sql
CREATE TABLE crec.comment (
    comment_id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL REFERENCES crec.user_account(user_id),
    falcon_id INTEGER NOT NULL REFERENCES crec.falcon(falcon_id)
);
```

---

## 8. Lancer le serveur Flask


```bash
python3 run.py
```

Le serveur sera accessible à l’adresse :

http://127.0.0.1:5000

---

## 9. Arrêter le serveur

Dans le terminal :

Ctrl + C
