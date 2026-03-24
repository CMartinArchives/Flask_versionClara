from flask import Blueprint, jsonify
from sqlalchemy import text  # ← ajoutez cet import

# Création du Blueprint
test_bp = Blueprint('test_bp', __name__)

@test_bp.route("/test")
def test():
    from ..app import db # pas compris pourquoi il doit être là et pas en haut honnêtement, aucune idée.
    result = db.session.execute(text('SELECT * FROM crec.bird_detection')).fetchall() 
   # On transforme les lignes en une liste de dictionnaires pour le JSON
    data = [dict(row._mapping) for row in result]
    return jsonify(data)


    