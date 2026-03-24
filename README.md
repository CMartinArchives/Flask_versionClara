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

## 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

---

## 4. Configurer les variables d’environnement

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

## 5. Vérifier que la base PostgreSQL existe

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

## 6. Lancer le serveur Flask

```bash
python3 run.py
```

Le serveur sera accessible à l’adresse :

http://127.0.0.1:5000

---

## 7. Arrêter le serveur

Dans le terminal :

Ctrl + C
