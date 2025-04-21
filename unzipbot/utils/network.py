from aiofiles import open as openfile
from aiohttp import ClientSession, InvalidURL
from unzip_http import RemoteZipFile

from unzipbot import LOGGER
from unzipbot.config.config import Config
from unzipbot.i18n.messages import messages


async def download(url: str, path: str) -> None:
    try:
        async with (
            ClientSession() as session,
            session.get(url=url, timeout=None, allow_redirects=True) as resp,
            openfile(file=path, mode="wb") as file,
        ):
            async for chunk in resp.content.iter_chunked(Config.CHUNK_SIZE):
                await file.write(chunk)
    except InvalidURL:
        LOGGER.error(msg=messages.get(file="callbacks", key="INVALID_URL"))
    except Exception:
        LOGGER.error(msg=messages.get(file="callbacks", key="ERR_DL", extra_args=url))


def get_zip_http(url: str) -> tuple[RemoteZipFile, list[str]]:
    rzf = RemoteZipFile(url)
    paths: list[str] = rzf.namelist()
    return rzf, paths
