import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.database.models.dates_models import Base

SQLITE_DB = "liverpool_dates.db"

logger = logging.getLogger(__name__)


def setup_database(db_url=None):
    """Set up the SQLite database. If no db_url is provided, use the default file-based database."""
    if db_url is None:
        db_url = f"sqlite:///{SQLITE_DB}"  # pragma: no cover
    engine = create_engine(f'sqlite:///{SQLITE_DB}')
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    return Session()


if __name__ == "__main__":  # pragma: no cover
    session = setup_database()
    print("Database setup completed!")
