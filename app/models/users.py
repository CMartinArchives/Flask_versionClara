from flask_login import LoginManager, UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from ..app import app, db

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"


class User(UserMixin, db.Model):
    __tablename__ = "user_account"
    __table_args__ = {"schema": "crec"}

    user_id = db.Column(db.Integer, primary_key=True)

    username = db.Column(
        db.String(80),
        unique=True,
        nullable=False
    )

    email = db.Column(
        db.String(120),
        unique=True,
        nullable=False
    )

    password_hash = db.Column(
        db.String(255),
        nullable=False
    )

    bio = db.Column(db.Text)

    # relation vers les commentaires
    comments = db.relationship(
        "Comment",
        backref="author",
        lazy=True
    )

    def get_id(self):
        return str(self.user_id)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)


@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))