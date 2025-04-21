# List of error messages from 7zip
ERROR_MSGS = ["Error", "Can't open as archive"]

# List of common extentions
extentions_list = {
    "archive": [
        "7z",
        "apk",
        "apkm",
        "apks",
        "appx",
        "arc",
        "bcm",
        "bin",
        "br",
        "bz2",
        "dmg",
        "exe",
        "gz",
        "img",
        "ipsw",
        "iso",
        "jar",
        "lz4",
        "msi",
        "paf",
        "pak",
        "pea",
        "pkg",
        "rar",
        "tar",
        "tgz",
        "wim",
        "x7",
        "xapk",
        "xz",
        "z",
        "zip",
        "zipx",
        "zpaq",
        "zst",
        "zstd",
    ],
    "audio": ["aac", "aif", "aiff", "alac", "flac", "m4a", "mp3", "ogg", "wav", "wma"],
    "photo": ["gif", "jpg", "jpeg", "png", "tiff", "webp"],
    "split": ["0*", "001", "002", "003", "004", "005", "006", "007", "008", "009"],
    "video": ["3gp", "avi", "flv", "mp4", "mkv", "mov", "mpeg", "mpg", "webm"],
}

tarball_extensions = (
    ".tar.gz",
    ".gz",
    ".tgz",
    ".taz",
    ".tar.bz2",
    ".bz2",
    ".tb2",
    ".tbz",
    ".tbz2",
    ".tz2",
    ".tar.lz",
    ".lz",
    ".tar.lzma",
    ".lzma",
    ".tlz",
    ".tar.lzo",
    ".lzo",
    ".tar.xz",
    ".xz",
    ".txz",
    ".tar.z",
    ".z",
    ".tz",
    ".taz",
)

# Regex for urls
https_url_regex = r"((http|https)\:\/\/)?[a-zA-Z0-9\.\/\?\:@\-_=#]+\.([a-zA-Z]){2,6}([a-zA-Z0-9\.\&\/\?\:@\-_=#])*"  # noqa: E501

split_file_pattern = r"\.z\d+$"
rar_file_pattern = r"\.(?:r\d+|part\d+\.rar)$"
volume_file_pattern = r"\.\d+$"
telegram_url_pattern = r"(?:http[s]?:\/\/)?(?:www\.)?t\.me\/([a-zA-Z0-9_]+)\/(\d+)"
