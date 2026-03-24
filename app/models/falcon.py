from ..app import db


class Falcon(db.Model):
    __tablename__ = "falcon"
    __table_args__ = {"schema": "crec"}

    falcon_id = db.Column(
        db.Integer,
        primary_key=True
    )

    falcon_code = db.Column(
        db.Text,
        unique=True,
        nullable=False
    )

    tag_id = db.Column(
        db.Text
    )

    nickname = db.Column(
        db.Text,
        nullable=False
    )

    # relation vers les commentaires
    comments = db.relationship(
        "Comment",
        backref="falcon",
        lazy=True
    )