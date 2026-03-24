from datetime import datetime
from ..app import db


class Comment(db.Model):
    __tablename__ = "comment"
    __table_args__ = {"schema": "crec"}

    comment_id = db.Column(
        db.Integer,
        primary_key=True
    )

    content = db.Column(
        db.Text,
        nullable=False
    )

    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        nullable=False
    )

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("crec.user_account.user_id"),
        nullable=False
    )

    falcon_id = db.Column(
        db.Integer,
        db.ForeignKey("crec.falcon.falcon_id"),
        nullable=False
    )