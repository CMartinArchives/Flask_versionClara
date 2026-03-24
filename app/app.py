from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from .config import Config
from .routes.test import test_bp

app = Flask(
    __name__,
    template_folder="templates",
    static_folder="static"
)

app.config.from_object(Config)
app.secret_key = "dev"

db = SQLAlchemy(app)

from .routes import generales