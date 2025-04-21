from os.path import join

from defaults import Defaults
from env import Env
from psutil import cpu_count


class Config:
    APP_ID = int(Env.APP_ID or 0)
    API_HASH: str = Env.API_HASH or ""
    BASE_LANGUAGE: str = Env.BASE_LANGUAGE or Defaults.BASE_LANGUAGE
    BOT_TOKEN: str = Env.BOT_TOKEN or ""
    BOT_THUMB: str = join(Env.ROOT_DIR, "bot_thumb.jpg")
    BOT_OWNER = int(Env.BOT_OWNER or 0)
    # Default chunk size (10 Mb), increase if you need faster downloads
    CHUNK_SIZE = 1024 * 1024 * 10
    DOWNLOAD_LOCATION: str = join(Env.ROOT_DIR, "Downloads")
    IS_HEROKU: bool = (Env.DYNO or "").startswith("worker.")
    LOCKFILE = "/tmp/unzipbot.lock"
    LOGS_CHANNEL = int(Env.LOGS_CHANNEL or 0)
    MAX_CONCURRENT_TASKS = 75
    MAX_MESSAGE_LENGTH = 4096
    MAX_CPU_CORES_COUNT = cpu_count(logical=False)
    MAX_CPU_USAGE = 80
    # 512 MB by default for Heroku, unlimited otherwise
    MAX_RAM_AMOUNT_KB = 1024 * 512 if IS_HEROKU else -1
    MAX_RAM_USAGE = 80
    MAX_TASK_DURATION_EXTRACT = 120 * 60  # 2 hours (in seconds)
    MAX_TASK_DURATION_MERGE = 240 * 60  # 4 hours (in seconds)
    # Files under that size will not display a progress bar while uploading
    MIN_SIZE_PROGRESS = 1024 * 1024 * 50  # 50 MB
    MONGODB_URL = Env.MONGODB_URL or ""
    MONGODB_DBNAME = Env.MONGODB_DBNAME or Defaults.MONGODB_DBNAME
    TG_MAX_SIZE = 2097152000
    THUMB_LOCATION = join(Env.ROOT_DIR, "Thumbnails")
