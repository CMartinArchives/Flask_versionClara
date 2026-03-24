# Guide simple pour utiliser et compléter les templates Flask

Bonjour tout le monde,

J’ai préparé la base front de l’application Flask : les templates HTML en Jinja, le CSS global, une structure de navigation, plusieurs pages déjà stylisées, ainsi qu’un `run.py` minimal pour tester le rendu.

Vous pouvez maintenant brancher le backend dessus sans avoir à refaire toute la partie visuelle.

Ce guide présente d’abord la structure actuelle du projet et le rôle de chaque fichier, puis explique comment lancer le serveur Flask. Il détaille ensuite ce qui est déjà prêt côté interface, ce qu’il reste à développer côté backend, la logique Jinja déjà en place, des exemples de contenu statique à remplacer par des données dynamiques, les routes prévues de l’application et enfin les éléments de structure à ne pas modifier pour éviter de casser le fonctionnement des templates.

---

# 1. Arborescence actuelle

Voici l’arborescence de base du projet :

```text
projet_flask/
│
├── run.py
├── requirements.txt
├── venv/
│
└── app/
    ├── static/
    │   ├── css/
    │   │   └── style.css
    │   ├── img/
    │   │   └── logo-chartes-psl-coul.png
    │   └── js/
    │       └── main.js
    │
    └── templates/
        ├── base.html
        ├── index.html
        ├── map.html
        ├── search.html
        ├── birds.html
        ├── bird_detail.html
        ├── login.html
        ├── register.html
        ├── profile.html
        ├── methodology.html
        ├── dataviz.html
        ├── legal.html
        ├── 404.html
        │
        └── partials/
            ├── navbar.html
            └── footer.html
            └── search_form.html
```

---

# 2. À quoi sert chaque fichier

## run.py

C’est le fichier minimal qui permet de lancer Flask pour tester les pages.

Pour l’instant, il sert surtout à :
- déclarer les routes de base,
- faire fonctionner les templates,
- faire exister `current_user` via Flask-Login.

Plus tard, vous pourrez :
- le garder comme point d’entrée,
- ou réorganiser le projet en plusieurs fichiers (`routes.py`, `models.py`, etc.).

---

## base.html

C’est le template principal.

Toutes les pages héritent de lui avec :
```jinja
{% extends "base.html" %}
```

Il contient :
- le <head>
- le lien Bootstrap
- le lien vers style.css
- la navbar
- le footer
- la zone {% block content %}

En gros, si vous voulez changer quelque chose de global sur tout le site, il faut regarder ici.

---

## partials/navbar.html

Contient la barre de navigation.

Elle sert à naviguer entre :
- Accueil
- Explorer (menu déroulant)
- Méthodologie
- Connexion / Profil selon l’état utilisateur

Elle utilise déjà Jinja avec :
```jinja
{% if current_user.is_authenticated %}
```

Donc quand le vrai système de connexion sera branché, la navbar s’adaptera automatiquement.

---

## partials/footer.html

Contient le footer du site.

On y trouve :
- le logo Chartes | PSL
- le contexte du projet
- les noms du groupe
- le lien vers les mentions légales

Le logo renvoie vers le site de l’École des chartes.

---

## partials/search_form.html

Contient le formulaire de recherche réutilisable.

L’idée, c’est d’éviter de recopier le même formulaire dans plusieurs pages.

Il peut être inclus avec :
```jinja
{% include 'partials/search_form.html' %}
```

Il sert surtout dans :
- search.html
- éventuellement map.html si vous voulez réutiliser les mêmes filtres

Il contient la structure visuelle du formulaire :
- nom de l’oiseau
- date
- région
- bouton de recherche

Plus tard, ce formulaire pourra être relié aux vraies données et aux vrais paramètres de requête.

---

## index.html

Page d’accueil.

Elle sert à présenter :
- le projet,
- le faucon crécerelle,
- l’intérêt scientifique de l’application,
- les accès aux pages principales,
- le lien vers la méthodologie.

C’est la vitrine de l’application.

---

## map.html

Page de la carte.

Pour l’instant, elle contient :
- une structure de page,
- une zone “placeholder” de carte,
- un espace pour les futurs filtres.

Plus tard, il faudra y brancher :
- la vraie carte JS,
- les coordonnées GPS,
- éventuellement les filtres par oiseau / date / région.

---

## search.html

Page de recherche.

Elle sert à accueillir :
- un formulaire de recherche,
- un tableau de résultats.

Le design est déjà prêt.
Il restera à relier le formulaire aux vraies données.

---

## birds.html

Page liste des oiseaux.

Elle sert à :
- afficher plusieurs oiseaux,
- donner accès aux fiches individuelles.

Pour l’instant il y a des exemples statiques.
Plus tard vous pourrez générer la liste avec une boucle Jinja :
```jinja
{% for bird in birds %}
```

---

## bird_detail.html

Page fiche détaillée d’un oiseau.

Elle contient :
- les informations de base sur l’oiseau,
- une mini zone carte,
- les commentaires,
- un formulaire de commentaire si l’utilisateur est connecté,
- un bouton “Se connecter” sinon.

C’est une page importante, car elle montre :
- la lecture de données,
- l’écriture de commentaires,
- la gestion utilisateur.

---

## login.html

Page de connexion.

Elle contient le formulaire de connexion visuel.

Il faudra ensuite :
- brancher le vrai formulaire Flask,
- vérifier les identifiants,
- connecter l’utilisateur avec Flask-Login.

---

## register.html

Page d’inscription.

Elle contient :
- identifiant,
- adresse mail,
- mot de passe,
- confirmation,
- présentation personnelle facultative.

C’est la base de création de compte.

---

## profile.html

Page profil utilisateur.

Elle contient pour l’instant :
- un exemple d’identifiant,
- un mail,
- une présentation,
- des commentaires écrits.

J’ai aussi laissé des commentaires dans le code pour montrer ce qui pourra être remplacé plus tard par :
- current_user.username
- current_user.email
- current_user.bio
- une boucle sur les commentaires de l’utilisateur.

---

## methodology.html

Page méthodologie.

Elle présente :
- le contexte scientifique,
- le périmètre d’étude,
- l’origine des données,
- la construction de la base relationnelle,
- les choix techniques,
- la logique générale du pipeline.

Les blocs Movebank, AEMET et Wikidata renvoient aux sites des sources.

---

## dataviz.html

Page des visualisations Tableau.

Elle intègre :
- le nuage de points,
- la heatmap,
- la carte,

via les codes d’intégration Tableau Public.

Les visualisations sont déjà intégrées dans le HTML.

---

## legal.html

Page mentions légales.

Elle sert à :
- préciser le cadre universitaire,
- présenter les auteurs,
- expliquer la réutilisation des contenus,
- cadrer les données utilisées.

---

## 404.html

Page erreur simple.
Elle servira si une page n’existe pas.

---

## style.css

Fichier CSS principal.

Il contient tous les styles du site :
- navbar
- footer
- boutons
- homepage
- méthodologie
- dataviz
- birds
- profile
- placeholders map

Il est déjà structuré par sections.

---

## main.js

Pour l’instant, il est vide ou très léger.
Il pourra servir plus tard pour :
- la carte,
- les interactions JavaScript,
- de petits comportements front.

---

# 3. Comment lancer le serveur

## Étape 1 — se placer dans le projet

```bash
cd ~projet_flask
```

## Étape 2 — activer l’environnement virtuel

Sur Linux / Ubuntu :

```bash
source venv/bin/activate
```

## Étape 3 — installer les dépendances si besoin

Si vous venez de copier le projet ou de le récupérer depuis Git :

```bash
pip install -r requirements.txt
```

## Étape 4 — lancer le serveur
```bash
python run.py
```

Ensuite ouvrir dans le navigateur :

http://127.0.0.1:5000

## Si Flask ne se lance pas
Erreur : No module named flask

Cela veut dire que le venv n’est pas activé ou que Flask n’est pas installé.

Dans ce cas :
```bash
source venv/bin/activate
pip install -r requirements.txt
```

---

# 4. Ce qui est déjà prêt

Vous n’avez pas à refaire :
- la structure des pages
- la base Jinja
- la navbar
- le footer
- le CSS global
- la page d’accueil
- la méthodologie
- les pages profil / connexion / inscription
- la page dataviz
- la page liste d’oiseaux

En gros, la couche visuelle de base est prête.

---

# 5. Ce qu’il faut faire maintenant

La suite, c’est surtout du backend et du branchement.

## Priorité 1 — brancher la base de données

Il faut relier l’application Flask à la base issue du travail précédent.

À faire :
- connexion SQLite
- définition des modèles ORM
- relation entre oiseaux, commentaires, utilisateurs, etc.


## Priorité 2 — mettre en place les utilisateurs

Il faut brancher le vrai système utilisateur.

À faire :
- modèle User
- inscription réelle
- connexion réelle
- gestion du mot de passe hashé
- Flask-Login proprement connecté

Le front est déjà prêt pour ça.


## Priorité 3 — rendre dynamiques les pages statiques

Aujourd’hui, certaines pages ont encore des données d’exemple.

Il faudra remplacer :
- les faux oiseaux de birds.html
- la fausse fiche de bird_detail.html
- les faux commentaires de profile.html
- les contenus statiques de recherche

par des variables Jinja, par exemple :

```jinja
{{ bird.name }}
{{ current_user.username }}
{% for comment in comments %}
```


## Priorité 4 — brancher les commentaires

Le front de bird_detail.html est prêt.

Il faudra :
- enregistrer les commentaires en base
- lier chaque commentaire à un utilisateur
- lier chaque commentaire à un oiseau
- afficher les commentaires réels
- afficher dans le profil les commentaires écrits par l’utilisateur


## Priorité 5 — brancher la carte

La page map.html est prête visuellement, mais pas encore fonctionnelle.

Il faudra :
- choisir la bibliothèque JS de carte
- envoyer les données GPS à la carte
- afficher les points / trajectoires
- éventuellement ajouter les filtres


## Priorité 6 — brancher la recherche

La page search.html doit être reliée à la base.

Il faudra :
- récupérer les paramètres du formulaire
- lancer les requêtes
- afficher les résultats dans le tableau

---

# 6. Logique Jinja déjà en place

Le projet utilise déjà Jinja.

Concrètement, il y a déjà :
- extends
- block
- include
- conditions avec if
- espaces prévus pour les futures boucles

Exemples :

```jinja
{% extends "base.html" %}
{% block content %}{% endblock %}
{% include 'partials/navbar.html' %}
{% if current_user.is_authenticated %}
```

Donc quand vous brancherez le backend, il faudra surtout remplacer les exemples statiques par des variables.

---

# 7. Exemples de ce qu’il faudra remplacer plus tard

## Dans profile.html

Aujourd’hui :

```html
<p><strong>Identifiant :</strong> clara123</p>
```

Plus tard :

```jinja
<p><strong>Identifiant :</strong> {{ current_user.username }}</p>
```

## Dans birds.html

Aujourd’hui : 3 oiseaux écrits à la main.

Plus tard :

```jinja
{% for bird in birds %}
```

## Dans bird_detail.html

Aujourd’hui : commentaires d’exemple.

Plus tard :
```jinja
{% for comment in comments %}
```

---

# 8. Routes actuellement prévues

Le `run.py` minimal doit permettre d’accéder à ces routes :

- `/` → accueil  
- `/map` → carte  
- `/search` → recherche  
- `/birds` → liste des oiseaux  
- `/bird` → fiche oiseau  
- `/login` → connexion  
- `/register` → inscription  
- `/profile` → profil  
- `/methodology` → méthodologie  
- `/dataviz` → datavisualisations  
- `/legal` → mentions légales  

Si vous changez les noms des routes, pensez à mettre à jour les `url_for(...)` dans les templates.

---

# 9. Ce qu’il ne faut pas casser

Merci de faire attention à :
- garder base.html comme base commune
- garder les noms de templates si possible
- ne pas supprimer les url_for(...)
- ne pas casser la structure app/templates et app/static
- ne pas déplacer le CSS sans mettre à jour les liens