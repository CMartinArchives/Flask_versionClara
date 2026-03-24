import json
import csv

donnees = []
pas = 1000  # 1 point sur 1000 pour plus de lisibilité

with open('donnees.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f, delimiter=',')
    for i, row in enumerate(reader):
        if i % pas == 0:
            if row['location-long'] and row['location-lat']:
                donnees.append(row)

# Trier par timestamp
donnees.sort(key=lambda x: x['timestamp'])

features = []
for row in donnees:
    feature = {
        "type": "Feature",
        "geometry": {
            "type": "Point",
            "coordinates": [
                float(row['location-long']),
                float(row['location-lat'])
            ]
        },
        "properties": {
            "nom": row['individual-local-identifier'],
            "timestamp": row['timestamp']
        }
    }
    features.append(feature)

geojson = {
    "type": "FeatureCollection",
    "features": features
}

with open('app/static/data/data_js.json', 'w', encoding='utf-8') as f:
    json.dump(geojson, f, indent=2, ensure_ascii=False)

print(f"✅ {len(features)} points exportés dans app/static/data/data_js.json !")