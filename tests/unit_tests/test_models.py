import os
import pytest
from sqlalchemy import inspect
from sqlalchemy.exc import IntegrityError
from backend.database.load_dates_db import load_initial_data
from backend.database.models.dates_models import DateIdea, Tag
from backend.database.setup_dates_db import setup_database, SQLITE_DB


class TestCRUD:

    @pytest.fixture(autouse=True)
    def setup_and_teardown(self, db_session_dates, sample_date_idea):
        """Setup and teardown for each test."""
        self.session = db_session_dates
        self.sample_date_idea = sample_date_idea

        yield

    def test_setup_database(self):
        """Test the setup of the SQLite database."""
        session = setup_database(db_url="sqlite:///:memory:")
        assert os.path.exists(SQLITE_DB), f"Database file {SQLITE_DB} was not created."
        inspector = inspect(session.get_bind())
        tables = inspector.get_table_names()

        assert 'date_ideas' in tables

    def test_load_initial_data(self, temp_json_file_dates):
        """Test loading initial data from JSON using the temporary file fixture."""
        load_initial_data(self.session, temp_json_file_dates)

        date_ideas = self.session.query(DateIdea).all()
        assert len(date_ideas) == 2
        assert date_ideas[0].title == "Sample Date Idea 1"
        assert date_ideas[1].title == "Sample Date Idea 2"

    def test_load_initial_data_invalid_json(self, invalid_json_file):
        """Test loading initial data from an invalid JSON file."""
        date_ideas = self.session.query(DateIdea).all()
        with pytest.raises(Exception):
            load_initial_data(self.session, invalid_json_file)

        date_ideas = self.session.query(DateIdea).all()
        assert len(date_ideas) == 0

    def test_create(self):
        """Test creating a new DateIdea."""
        tags = []
        for tag_name in ["romantic", "dinner", "food"]:
            tag = Tag.create(self.session, name=tag_name)  # Use the Tag's `create` method
            tags.append(tag)

        date_idea_data = self.sample_date_idea.copy()
        date_idea_data["tags"] = tags  # Add the tags list to the data

        date_idea = DateIdea.create(self.session, **date_idea_data)

        assert date_idea.id is not None
        assert date_idea.title == self.sample_date_idea["title"]
        assert len(date_idea.tags) == len(tags)  # Check if the tags were correctly associated

    def test_get_by_id(self):
        """Test retrieving a DateIdea by ID."""
        created_date_idea = DateIdea.create(self.session, **self.sample_date_idea)
        fetched_date_idea = DateIdea.get_by_id(self.session, created_date_idea.id)
        assert fetched_date_idea is not None
        assert fetched_date_idea.id == created_date_idea.id

    def test_update(self):
        """Test updating an existing DateIdea."""
        created_date_idea = DateIdea.create(self.session, **self.sample_date_idea)
        new_title = "Updated Date Idea"
        created_date_idea.update(self.session, title=new_title)
        updated_date_idea = DateIdea.get_by_id(self.session, created_date_idea.id)

        assert updated_date_idea is not None, "Expected an updated DateIdea but got None."
        assert updated_date_idea.title == new_title, f"Expected title '{new_title}', but is '{updated_date_idea.title}'"

    def test_delete(self):
        """Test deleting a DateIdea."""
        created_date_idea = DateIdea.create(self.session, **self.sample_date_idea)
        created_date_idea.delete(self.session)
        deleted_date_idea = DateIdea.get_by_id(self.session, created_date_idea.id)
        assert deleted_date_idea is None

    def test_create_integrity_error(self):
        """Test IntegrityError when creating a DateIdea with missing fields."""
        with pytest.raises(IntegrityError):
            DateIdea.create(self.session, title="Invalid Date Idea")  # Missing required fields

    def test_get_by_id_no_result_found(self):
        """Test retrieving a DateIdea that does not exist."""
        result = DateIdea.get_by_id(self.session, id=999)
        assert result is None

    def test_update_integrity_error(self):
        """Test IntegrityError when updating a DateIdea with invalid data (e.g., None for a required field)."""
        created_date_idea = DateIdea.create(self.session, **self.sample_date_idea)
        new_title = None  # Invalid data for title

        # Ensure that an IntegrityError is raised due to the invalid update
        with pytest.raises(IntegrityError):
            created_date_idea.update(self.session, title=new_title)
