from os import environ
from pathlib import Path

pkg_name: str = Path(__file__).resolve().parents[1].name
PACKAGE_ROOT: Path = Path(__file__).resolve().parents[1]


class Env:
    APP_ID = environ.get("APP_ID")
    API_HASH = environ.get("API_HASH")
    BASE_LANGUAGE = environ.get("BASE_LANGUAGE")
    BOT_TOKEN = environ.get("BOT_TOKEN")
    BOT_OWNER = environ.get("BOT_OWNER")
    DYNO = environ.get("DYNO")
    LOGS_CHANNEL = environ.get("LOGS_CHANNEL")
    MONGODB_DBNAME = environ.get("MONGODB_DBNAME")
    MONGODB_URL = environ.get("MONGODB_URL")
    PACKAGE_NAME = pkg_name
    ROOT_DIR = str(PACKAGE_ROOT)
