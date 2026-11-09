"""Check the installable app layout inside an IPA, without extracting it."""

import argparse
import plistlib
import re
import zipfile


def verify_ipa(path):
    with zipfile.ZipFile(path) as archive:
        names = set(archive.namelist())
        app_plists = sorted(
            name for name in names
            if re.fullmatch(r"Payload/[^/]+\.app/Info\.plist", name)
        )
        if len(app_plists) != 1:
            if any(name.lower().endswith(".ipa") for name in names):
                raise ValueError(
                    "This is a ZIP containing an IPA. Extract the .ipa file first; "
                    "do not rename the download ZIP to .ipa."
                )
            raise ValueError(
                "Expected exactly one Payload/*.app/Info.plist at the archive root."
            )
        app_root = app_plists[0].rsplit("/", 1)[0]
        info = plistlib.loads(archive.read(app_plists[0]))
        executable = info.get("CFBundleExecutable")
        if not isinstance(executable, str) or not executable or "/" in executable:
            raise ValueError("Missing or invalid CFBundleExecutable in Info.plist.")
        executable_path = f"{app_root}/{executable}"
        if executable_path not in names or archive.getinfo(executable_path).file_size == 0:
            raise ValueError(f"Missing or empty app executable: {executable_path}")
        bad_file = archive.testzip()
        if bad_file:
            raise ValueError(f"Corrupt ZIP entry: {bad_file}")
        return app_root


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ipa")
    args = parser.parse_args()
    try:
        app_root = verify_ipa(args.ipa)
    except (OSError, ValueError, zipfile.BadZipFile, plistlib.InvalidFileException) as error:
        parser.exit(1, f"Invalid IPA: {error}\n")
    print(f"IPA layout and ZIP integrity verified: {app_root}")
