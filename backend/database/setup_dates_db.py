import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.database.models.dates_models import Base

SQLITE_DB = "original_dates.db"

logger = logging.getLogger(__name__)


def setup_database(db_url=None, sqlite_db=SQLITE_DB):
    """Set up the SQLite database. If no db_url is provided, use the default file-based database."""
    if db_url is None:
        db_url = f"sqlite:///{sqlite_db}"  # pragma: no cover
    engine = create_engine(f'sqlite:///{sqlite_db}')
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    return Session()


if __name__ == "__main__":  # pragma: no cover
    session = setup_database()
    print("Database setup completed!")
