from datetime import datetime, timezone
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship
from backend.extentions import db
from backend.database.models.user_models import User


class RevokedToken(db.Model):
    __tablename__ = 'revoked_tokens'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    jti = db.Column(db.String(255), nullable=False, unique=True)
    user_id = db.Column(db.Integer, ForeignKey('users.id'), nullable=False)
    revoked_at = db.Column(db.TIMESTAMP, default=datetime.now(timezone.utc))
    expires_at = db.Column(db.TIMESTAMP)
    reason = db.Column(db.String(255))

    user = relationship(User, backref='revoked_tokens')

    def __init__(self, jti, user_id, expires_at=None, reason=None):
        self.jti = jti
        self.user_id = user_id
        self.expires_at = expires_at
        self.reason = reason

    def __repr__(self):  # pragma: no cover
        return f"<RevokedToken(jti='{self.jti}', user_id={self.user_id}, revoked_at={self.revoked_at})>"
