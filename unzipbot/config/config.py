from os.path import join

from defaults import Defaults
from env import Env
from psutil import cpu_count


class Config:
    # ? Env vars, edit the .env file !!
    APP_ID = int(Env.APP_ID or 0)
    API_HASH: str = Env.API_HASH or ""
    BOT_TOKEN: str = Env.BOT_TOKEN or ""
    BOT_OWNER = int(Env.BOT_OWNER or 0)
    IS_HEROKU: bool = (Env.DYNO or "").startswith("worker.")
    LOGS_CHANNEL = int(Env.LOGS_CHANNEL or 0)
    MONGODB_DBNAME: str = Env.MONGODB_DBNAME or Defaults.MONGODB_DBNAME
    MONGODB_URL: str = Env.MONGODB_URL or ""

    # ? Things you might want to change
    BASE_LANGUAGE: str = Env.BASE_LANGUAGE or Defaults.BASE_LANGUAGE
    BOT_USERNAME = "@unzip_edm115bot"
    # Default chunk size (10 Mb), increase if you need faster downloads
    CHUNK_SIZE = 1024 * 1024 * 10
    DEV_CHANNEL = "@EDM115bots"
    DEV_GITHUB = "https://github.com/EDM115"
    DEV_NAME = "EDM115"
    DONATE_LINKS: dict[str, str] = {
        "Paypal": "https://www.paypal.me/8EDM115",
        "GitHub Sponsors": "https://github.com/sponsors/EDM115",
        "BuyMeACoffee": "https://www.buymeacoffee.com/edm115",
        "Directly in Telegram": "https://t.me/EDM115bots/698",
    }
    FRAMEWORK_DOCS: str = (
        dict(
            item.split(", ", 1)
            for item in Env.FRAMEWORK_METADATA.get_all(name="Project-URL") or []
        ).get("Documentation")
        or ""
    )
    FRAMEWORK_NAME: str = "/".join(
        (
            dict(
                item.split(", ", 1)
                for item in Env.FRAMEWORK_METADATA.get_all(name="Project-URL") or []
            ).get("Source")
            or ""
        ).rsplit("/", 2)[-2:]
    )
    MAX_CONCURRENT_TASKS = 75
    MAX_MESSAGE_LENGTH = 4096
    MAX_TASK_DURATION_EXTRACT = 120 * 60  # 2 hours (in seconds)
    MAX_TASK_DURATION_MERGE = 240 * 60  # 4 hours (in seconds)
    # Files under that size will not display a progress bar while uploading
    MIN_SIZE_PROGRESS = 1024 * 1024 * 50  # 50 MB
    PROGRESS_EMPTY = "⬡"
    PROGRESS_FULL = "⬢"
    RATE_LINK = "https://t.me/BotsArchive/2705"
    SOURCE_CODE = "https://github.com/EDM115/unzip-bot"
    SUPPORT_GROUP = "@EDM115_chat"

    # ? Sensible defaults
    BOT_THUMB: str = join(Env.ROOT_DIR, "bot_thumb.jpg")
    DOWNLOAD_LOCATION: str = join(Env.ROOT_DIR, "Downloads")
    LOCKFILE = "/tmp/unzipbot.lock"
    MAX_CPU_CORES_COUNT: int | None = cpu_count(logical=False)
    MAX_CPU_USAGE = 80
    # 512 MB by default for Heroku, unlimited otherwise
    MAX_RAM_AMOUNT_KB = 1024 * 512 if IS_HEROKU else -1
    MAX_RAM_USAGE = 80
    TG_MAX_SIZE = 2097152000
    THUMB_LOCATION: str = join(Env.ROOT_DIR, "Thumbnails")
