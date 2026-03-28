from flask import render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, login_required, current_user
from ..models.falcon import Falcon
from ..models.comment import Comment
from ..models.users import User
from ..app import app, db
import csv
import json
import os

@app.route("/")
def index():
    return render_template("index.html")


@app.route("/map")
def map_page():
    return render_template("map.html")


@app.route("/search")
def search():
    return render_template("search.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        login_value = request.form["login"]
        password = request.form["password"]

        user = User.query.filter(
            (User.username == login_value) | (User.email == login_value)
        ).first()

        if user and user.check_password(password):
            login_user(user)
            flash("Connexion réussie.")
            return redirect(url_for("profile"))

        flash("Identifiants incorrects.")
        return redirect(url_for("login"))

    return render_template("login.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form["username"].strip()
        email = request.form["email"].strip()
        password = request.form["password"]
        confirm_password = request.form["confirm_password"]
        bio = request.form.get("bio", "").strip()

        if password != confirm_password:
            flash("Les mots de passe ne correspondent pas.")
            return redirect(url_for("register"))

        existing_username = User.query.filter_by(username=username).first()
        if existing_username:
            flash("Cet identifiant existe déjà.")
            return redirect(url_for("register"))

        existing_email = User.query.filter_by(email=email).first()
        if existing_email:
            flash("Cette adresse mail existe déjà.")
            return redirect(url_for("register"))

        user = User(
            username=username,
            email=email,
            bio=bio
        )
        user.set_password(password)

        db.session.add(user)
        db.session.commit()

        flash("Compte créé. Vous pouvez vous connecter.")
        return redirect(url_for("login"))

    return render_template("register.html")


@app.route("/logout")
@login_required
def logout():
    logout_user()
    flash("Vous êtes déconnecté.")
    return redirect(url_for("index"))


@app.route("/bird/<string:falcon_id>", methods=["GET", "POST"])
def bird_detail(falcon_id):
    falcon = Falcon.query.get_or_404(falcon_id)

    if request.method == "POST":
        if not current_user.is_authenticated:
            flash("Connecte-toi pour laisser un commentaire.")
            return redirect(url_for("login"))

        content = request.form["comment"].strip()

        if not content:
            flash("Le commentaire ne peut pas être vide.")
            return redirect(url_for("bird_detail", falcon_id=falcon_id))

        comment = Comment(
            content=content,
            user_id=current_user.user_id,
            falcon_id=falcon.falcon_id
        )

        db.session.add(comment)
        db.session.commit()

        flash("Commentaire ajouté.")
        return redirect(url_for("bird_detail", falcon_id=falcon_id))

    comments = Comment.query.filter_by(
        falcon_id=falcon.falcon_id
    ).order_by(
        Comment.created_at.desc()
    ).all()

    return render_template(
        "bird_detail.html",
        bird=falcon,
        comments=comments
    )


@app.route("/bird")
def bird_detail_first():
    falcon = Falcon.query.first()

    return render_template(
        "bird_detail.html",
        bird=falcon,
        comments=[]
    )


@app.route("/profile")
@login_required
def profile():
    comments = Comment.query.filter_by(
        user_id=current_user.user_id
    ).order_by(
        Comment.created_at.desc()
    ).all()

    return render_template(
        "profile.html",
        comments=comments
    )


@app.route("/methodology")
def methodology():
    return render_template("methodology.html")


@app.route("/dataviz")
def dataviz():
    return render_template("dataviz.html")


@app.route("/birds")
def birds():
    # couleur unique par oiseau comme sur la carte
    couleurs = [
        '#e41a1c', '#377eb8', '#4daf4a', '#984ea3',
        '#ff7f00', '#a65628', '#f781bf', '#999999',
        '#17becf', '#bcbd22', '#ff9896', '#aec7e8'
    ]
    # Charger les surnoms
    surnoms_path = os.path.join(app.static_folder, 'data', 'surnoms.json')
    with open(surnoms_path, 'r', encoding='utf-8') as f:
        surnoms = json.load(f)

    oiseaux = []
    seen = set()

    with open('donnees.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            identifiant = row['individual-local-identifier']
            if identifiant not in seen:
                seen.add(identifiant)
                oiseaux.append({
                    'falcon_id': identifiant,
                    'falcon_code': identifiant,
                    'nickname': surnoms.get(identifiant, 'NONE'),
                    'tag_id': row.get('tag-local-identifier', None),
                    'espece': row.get('individual-taxon-canonical-name', 'Non renseignée')
                })

    return render_template("birds.html", birds=oiseaux)

@app.route("/legal")
def legal():
    return render_template("legal.html")


@app.errorhandler(404)
def page_not_found(error):
    return render_template("404.html"), 404