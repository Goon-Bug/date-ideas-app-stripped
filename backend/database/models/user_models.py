from sqlalchemy.sql import func
from backend.extentions import db, bcrypt
from flask_login import UserMixin
from backend.database.models.dates_models import CRUDMixin


class User(db.Model, CRUDMixin, UserMixin):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String, unique=True, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    password = db.Column(db.String, nullable=False)
    icon = db.Column(db.String, nullable=True)
    email_verified = db.Column(db.Boolean, default=False)
    verification_jwt = db.Column(db.String(255), nullable=True)
    jwt_expiration = db.Column(db.DateTime(timezone=True), nullable=True)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)
    role = db.Column(db.String(50), default="user", nullable=False)
    token_count = db.Column(db.Integer, nullable=False, default=0)

    def __init__(self, username, email, password, token_count, email_verified=False, role='user'):
        self.username = username
        self.email = email
        self.set_password(password)  # Ensure password is hashed
        self.email_verified = email_verified
        self.role = role
        self.token_count = token_count

    def __repr__(self):
        return f"<User(username='{self.username}', email='{self.email}')>"  # pragma: no cover

    def set_password(self, password):
        """Uses bcrypt to encrypt the password before setting"""
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        """Uses bcrypt to check the password hash"""
        return bcrypt.check_password_hash(self.password, password)

    @classmethod
    def from_json(cls, data):
        """Create a User instance from a JSON object."""
        kwargs = {
            'username': data.get('username', ''),
            'email': data.get('email', ''),
            'password': data.get('password', ''),
            'role': data.get('role', 'user'),
            'email_verified': data.get('email_verified', False),
            'token_count': data.get('token_count', 0)
        }
        user = cls(**kwargs)
        user.set_password(data.get('password', ''))
        return user

    def to_json(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'icon': self.icon,
            'email_verified': self.email_verified,
            'verification_jwt': self.verification_jwt,
            'jwt_expiration': self.jwt_expiration,
            'created_at': self.created_at.isoformat(),
            'role': self.role,
            'token_count': self.token_count
        }
