from importlib.metadata import PackageMetadata, metadata, version
from os import environ
from pathlib import Path

pkg_name: str = Path(__file__).resolve().parents[1].name
PACKAGE_ROOT: Path = Path(__file__).resolve().parents[1]


class Env:
    APP_ID: str | None = environ.get("APP_ID")
    API_HASH: str | None = environ.get("API_HASH")
    BASE_LANGUAGE: str | None = environ.get("BASE_LANGUAGE")
    BOT_TOKEN: str | None = environ.get("BOT_TOKEN")
    BOT_OWNER: str | None = environ.get("BOT_OWNER")
    DYNO: str | None = environ.get("DYNO")
    FRAMEWORK_METADATA: PackageMetadata = metadata("pyrofork")
    LOGS_CHANNEL: str | None = environ.get("LOGS_CHANNEL")
    MONGODB_DBNAME: str | None = environ.get("MONGODB_DBNAME")
    MONGODB_URL: str | None = environ.get("MONGODB_URL")
    PACKAGE_NAME: str = pkg_name
    ROOT_DIR = str(PACKAGE_ROOT)

    class Versions:
        PYROFORK: str = version("pyrofork")
        PYTHON = "3.12.10"  # TODO : grab this from terminal once cli is done
        UNZIPBOT = "7.3.0"
