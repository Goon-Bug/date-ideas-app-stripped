from datetime import datetime, timedelta, timezone
from flask_jwt_extended import create_access_token, get_jwt_identity, verify_jwt_in_request
from flask import request
from flask_mail import Message
from backend.database.models.revoked_tokens import User
from backend.extentions import db, mail
from password_strength import PasswordPolicy

policy = PasswordPolicy.from_names(length=8, uppercase=1, numbers=1, special=1, nonletters=0)


def get_user_id() -> str:
    try:
        verify_jwt_in_request()
        current_user = get_jwt_identity()
        if current_user:
            return str(current_user)
    except Exception:
        pass

    return request.remote_addr or "unknown"


def validate_password(password):  # pragma: no cover
    errors = policy.test(password)
    if errors:
        return False, errors
    return True, None


def generate_verification_token(user_email):
    expires_in = timedelta(minutes=10)
    token = create_access_token(identity=user_email, expires_delta=expires_in)

    user = User.query.filter_by(email=user_email).first()
    if user:
        user.update(db.session, verification_jwt=token)
        user.update(db.session, jwt_expiration=datetime.now(timezone.utc) + expires_in)
        db.session.commit()
    return token


def send_verification_email(user_email, verification_url):
    msg = Message(
        subject="Verify Your Email Address",
        recipients=[user_email],
        body=f"Click the link to verify your email address: {verification_url}",
    )
    mail.send(msg)
