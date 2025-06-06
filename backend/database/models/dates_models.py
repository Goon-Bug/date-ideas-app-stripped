import logging
from sqlalchemy import (
    Column,
    Integer,
    Text,
    String,
    Float,
    Enum,
    Table,
    ForeignKey,
    Index,
)
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.exc import IntegrityError, NoResultFound
from enum import Enum as PyEnum

SQLITE_DB = "local_dates.db"

logger = logging.getLogger(__name__)

Base = declarative_base()


class CostEnum(str, PyEnum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"


date_idea_tags = Table(
    "date_idea_tags",
    Base.metadata,
    Column("date_idea_id", Integer, ForeignKey("date_ideas.id"), primary_key=True),
    Column("tag_id", Integer, ForeignKey("tags.id"), primary_key=True),
)


class CRUDMixin:
    @classmethod
    def create(cls, session, **kwargs):
        instance = cls(**kwargs)
        logger.debug(f"Creating instance with values: {kwargs}")
        try:
            session.add(instance)
            session.commit()
            return instance
        except IntegrityError as e:
            session.rollback()
            logger.error(f"Integrity error during creation: {e}")
            raise
        except Exception as e:  # pragma: no cover
            session.rollback()
            logger.error(f"Unexpected error during creation: {e}")
            raise

    @classmethod
    def get_by_id(cls, session, id):
        try:
            return session.query(cls).filter_by(id=id).one()
        except NoResultFound as e:
            logger.error(f"No result found for id {id}: {e}")
            return None
        except Exception as e:  # pragma: no cover
            logger.error(f"Unexpected error during retrieval: {e}")
            raise

    def update(self, session, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)
        try:
            session.commit()
        except IntegrityError as e:
            session.rollback()
            logger.error(f"Integrity error during update: {e}")
            raise
        except Exception as e:  # pragma: no cover
            session.rollback()
            logger.error(f"Unexpected error during update: {e}")
            raise

    def delete(self, session):
        try:
            session.delete(self)
            session.commit()
        except Exception as e:  # pragma: no cover
            session.rollback()
            logger.error(f"Unexpected error during deletion: {e}")
            raise


class Tag(Base, CRUDMixin):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), unique=True, nullable=False)

    def __repr__(self):  # pragma: no cover
        return f"<Tag(id={self.id}, name={self.name})>"


class DateIdea(Base, CRUDMixin):
    __tablename__ = "date_ideas"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(Text, nullable=False)
    description = Column(Text, nullable=False)
    location = Column(Text, nullable=False)
    duration = Column(Float, nullable=False)  # Converted duration to float
    cost = Column(Enum(CostEnum), nullable=False)  # Enum for cost
    tags = relationship("Tag", secondary=date_idea_tags, backref="date_ideas")

    __table_args__ = (
        Index("ix_date_ideas_title", "title"),
    )

    def __repr__(self):  # pragma: no cover
        return (
            f"<DateIdea(id={self.id},"
            f"title={self.title}, description={self.description}, "
            f"location={self.location}, duration={self.duration}, "
            f"cost={self.cost}, tags={[tag.name for tag in self.tags]})>"
        )


class Timeline(Base, CRUDMixin):
    __tablename__ = "timeline"

    id = Column(Integer, primary_key=True, autoincrement=True)
    date_id = Column(Integer, ForeignKey("date_ideas.id"), nullable=False)
    image_path = Column(Text, nullable=False)
    user_id = Column(Integer, nullable=False)
    description = Column(Text, nullable=True)

    date_idea = relationship("DateIdea", backref="timeline_items")

    def __repr__(self):  # pragma: no cover
        return (
            f"<Timeline(id={self.id}, date_id={self.date_id}, "
            f"image_path={self.image_path}, user_id={self.user_id}, "
            f"description={self.description})>"
        )
