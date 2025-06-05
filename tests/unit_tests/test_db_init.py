from datetime import timedelta
from backend import create_app


def test_development_config(monkeypatch):
    """Test the Flask app configuration in development mode."""

    monkeypatch.setenv("FLASK_SECRET_KEY", "dev_secret_key")
    monkeypatch.setenv("JWT_SECRET_KEY", "dev_jwt_secret_key")
    monkeypatch.setenv("DATABASE_URL", "sqlite:///dev_test.db")

    app = create_app(config_mode='development')

    assert app.config["SECRET_KEY"] == "dev_secret_key"
    assert app.config["JWT_SECRET_KEY"] == "dev_jwt_secret_key"
    assert app.config["SQLALCHEMY_DATABASE_URI"] == "sqlite:///dev_test.db"
    assert app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] is False
    assert app.config["SESSION_COOKIE_SECURE"] is True
    assert app.config["PERMANENT_SESSION_LIFETIME"] == 3600
    assert app.config['JWT_ACCESS_TOKEN_EXPIRES'] == timedelta(hours=1)
    assert app.config['JWT_REFRESH_TOKEN_EXPIRES'] == timedelta(days=30)
