import os
from flask import Flask
from datetime import datetime, timedelta, timezone
from backend.extentions import db
from models.user_models import User


def create_task_app():
    app = Flask(__name__)

    app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    return app


app = create_task_app()
with app.app_context():
    cutoff = datetime.now(timezone.utc) - timedelta(days=2)
    users = User.query.filter_by(email_verified=False).filter(User.created_at < cutoff).all()

    print(f"Deleting {len(users)} unverified users...")
    for user in users:
        db.session.delete(user)

    db.session.commit()
    print("Done.")
