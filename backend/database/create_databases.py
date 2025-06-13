from load_dates_db import load_initial_data
from setup_dates_db import setup_database

if __name__ == "__main__":  # pragma: no cover
    session = setup_database(sqlite_db='original_dates.db')
    print("Database setup completed!")
    try:
        load_initial_data(session, 'frontend/flutter/my_app/assets/db/jsons/original_date_ideas.json')
    except Exception as e:
        print(f"An error occurred while loading initial data: {e}")
    finally:
        session.close()
