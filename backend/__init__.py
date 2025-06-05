from flask import Flask
from backend.extentions import db, bcrypt, migrate, jwt, mail, talisman
from datetime import timedelta
import os


def create_app(config_mode='development'):
    app = Flask(__name__)

    app.config['MAIL_SERVER'] = 'smtp.gmail.com'
    app.config['MAIL_PORT'] = 587
    app.config['MAIL_USE_TLS'] = True
    app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
    app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
    app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_USERNAME')

    if config_mode == 'testing':
        app.config.from_mapping(
            SECRET_KEY="testing_secret_key",
            SQLALCHEMY_DATABASE_URI="sqlite:///:memory:",
            SQLALCHEMY_TRACK_MODIFICATIONS=False,
            SESSION_COOKIE_SECURE=False,
            JWT_SECRET_KEY="testing_jwt_secret_key",
            JWT_ACCESS_TOKEN_EXPIRES=timedelta(hours=1),
            JWT_REFRESH_TOKEN_EXPIRES=timedelta(days=30),
            TESTING=True,
            WTF_CSRF_ENABLED=False,
        )
    elif config_mode == 'development':
        app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY")
        app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")
        app.config['JWT_EXPIRATION_DELTA'] = 3600
        app.config["JWT_TOKEN_LOCATION"] = ["headers"]
        app.config["JWT_HEADER_NAME"] = "Authorization"
        app.config["JWT_HEADER_TYPE"] = "Bearer"
        app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
        app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
        app.config["SESSION_COOKIE_SECURE"] = True
        app.config["PERMANENT_SESSION_LIFETIME"] = 3600
        app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(minutes=5)  # 1 minute for testing
        app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=30)

    db.init_app(app)
    bcrypt.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    mail.init_app(app)

    if config_mode != 'testing':
        csp = {"default-src": ["'self'"]}
        talisman.init_app(app, content_security_policy=csp, force_https=False)

    from backend.routes import register_routes
    register_routes(app)

    return app
