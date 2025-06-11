import json
import logging
from backend.database.models.dates_models import DateIdea, Tag
from backend.database.setup_dates_db import setup_database

SQLITE_DB = "original_dates.db"

logger = logging.getLogger(__name__)


def load_initial_data(session, json_file):
    try:
        with open(json_file, 'r') as file:
            date_ideas = json.load(file)

        for idea in date_ideas:
            print(f"Loading date idea: {idea}")

            # Ensure tags are Tag objects, not just strings
            tags = []
            for tag_name in idea['tags']:
                # Retrieve the tag from the database, or create a new one if it doesn't exist
                tag = session.query(Tag).filter_by(name=tag_name).first()
                if not tag:
                    # If the tag does not exist, create a new Tag object
                    tag = Tag(name=tag_name)
                    session.add(tag)
                    session.flush()  # Ensure the tag is committed and has an ID
                if tag not in tags:
                    tags.append(tag)

            # Create a DateIdea object with all fields including tags
            date_idea = DateIdea(
                title=idea['title'],
                pack=idea['pack'],
                description=idea['description'],
                location=", ".join(idea['location']) if isinstance(idea['location'], list) else idea['location'],
                duration=idea['duration'],
                cost=idea['cost']
            )

            # Add the tags to the DateIdea's relationship field
            date_idea.tags.extend(tags)

            # Add the DateIdea to the session
            session.add(date_idea)
            session.commit()

    except Exception as e:
        logger.error(f"An error occurred while loading initial data: {e}")
        raise


if __name__ == "__main__":  # pragma: no cover
    session = setup_database()
    load_initial_data(session, 'backend/jsons/final_jsons/original_date_ideas.json')
    session.close()
