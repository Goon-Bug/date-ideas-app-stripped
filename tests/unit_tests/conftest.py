import pytest
import os
import json
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from backend.database.models.dates_models import Base, Tag
from backend.database.models.user_models import User  # type: ignore
from backend import create_app, db  # type: ignore


@pytest.fixture(autouse=True)
def print_database_contents(app):
    """Prints the contents of the users table before each test."""

    # Create an application context
    with app.app_context():
        yield  # This allows the test to run

        # Code after yield runs after the test
        users = User.query.all()  # Fetch all users from the database
        print("\nCurrent Users in the Database:")
        for user in users:
            print(user.to_json())


@pytest.fixture
def invalid_json_file(tmp_path):
    """Fixture to create an invalid JSON file."""
    invalid_file_path = tmp_path / "invalid_file.json"
    with open(invalid_file_path, 'w') as file:
        file.write("{ invalid json }")  # Not valid JSON format
    yield invalid_file_path


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECTION: User Fixtures
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


@pytest.fixture(scope="function")
def app(sample_user):
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        db.session.add(User.from_json(sample_user))
        db.session.commit()
        yield app
        db.session.remove()  # Cleanup
        db.drop_all()


@pytest.fixture(scope="function")
def client(app):
    return app.test_client()


@pytest.fixture
def sample_user():
    return {
        'id': 1,
        'username': 'testuser',
        'email': 'testuser@example.com',
        'password': 'TestPassword1!',
        'email_verified': True,
    }


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECTION: Dates Fixtures
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


@pytest.fixture(scope="function")
def db_session_dates():
    """Fixture to provide a temporary SQLite database session."""
    db_file = "temp_local_dates.db"
    engine = create_engine(f"sqlite:///{db_file}")
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()

    yield session

    session.close()
    engine.dispose()

    if os.path.exists(db_file):
        os.remove(db_file)


@pytest.fixture
def sample_date_idea(db_session_dates):
    """Fixture for a sample DateIdea instance with tags."""
    # Create some tags
    tags = [Tag(name="sample_tag")]
    # Add tags to the session and commit
    for tag in tags:
        db_session_dates.add(tag)
    db_session_dates.commit()

    # Return the dictionary with the DateIdea data, including the tags
    return {
        "title": "Sample Date Idea",
        "description": "This is a sample date idea.",
        "location": "Sample Location",
        "duration": 2.5,  # Duration should be a float
        "tags": tags,  # Pass the list of Tag objects here
        "cost": "Low",
    }


@pytest.fixture
def temp_json_file_dates():
    """Fixture to create and remove a temporary JSON file."""
    sample_json = [
        {
            "title": "Sample Date Idea 1",
            "description": "A fun date idea.",
            "location": "Park",
            "duration": 1.5,
            "cost": "Low",
            "tags": ["sample_tag"],  # Tags are now a list of strings
        },
        {
            "title": "Sample Date Idea 2",
            "description": "A romantic date idea.",
            "location": "Restaurant",
            "duration": 2.5,
            "cost": "Medium",
            "tags": ["sample_tag"],  # Tags are now a list of strings
        }
    ]

    json_file_path = 'test_date_ideas.json'
    with open(json_file_path, 'w') as file:
        json.dump(sample_json, file)

    yield json_file_path

    os.remove(json_file_path)
