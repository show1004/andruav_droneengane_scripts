#!/usr/bin/env python3
"""Helper to read/write FCB connection + MAVLink IDs in de_mavlink.config.module.json.

Handles JSON-with-comments by stripping C-style comments before parsing.
On write, does a targeted update of only `fcb_connection_uri` and `mavlink_ids`,
preserving all other keys. Backs up the original file before writing.

Usage:
  de_mavlink_config_helper.py read
  de_mavlink_config_helper.py write <json_string>
"""

import json
import re
import sys
import os
import shutil
from datetime import datetime

# Hardcoded to /home/pi because cockpit runs this via superuser (root),
# where os.path.expanduser("~") resolves to /root.
CONFIG_PATH = "/home/pi/drone_engage/de_mavlink/de_mavlink.config.module.json"
BACKUP_DIR = "/home/pi/drone_engage/de_mavlink/config_backups"

# Keys this tool manages
MANAGED_KEYS = ["fcb_connection_uri", "mavlink_ids"]


def strip_comments(text):
    """Remove // and /* */ comments from JSON text (preserves strings)."""
    def replacer(match):
        s = match.group(0)
        if s.startswith("/"):
            return ""
        return s
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE,
    )
    return re.sub(pattern, replacer, text)


def read_config():
    with open(CONFIG_PATH, "r") as f:
        raw = f.read()
    clean = strip_comments(raw)
    data = json.loads(clean)
    result = {}
    for key in MANAGED_KEYS:
        if key in data:
            result[key] = data[key]
    return result


def write_config(updates):
    """Update only managed keys in the config file, preserving the rest."""
    with open(CONFIG_PATH, "r") as f:
        raw = f.read()
    clean = strip_comments(raw)
    data = json.loads(clean)

    for key in MANAGED_KEYS:
        if key in updates:
            data[key] = updates[key]

    # Backup original
    os.makedirs(BACKUP_DIR, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(BACKUP_DIR, f"de_mavlink.config.module.json.bak.{ts}")
    shutil.copy2(CONFIG_PATH, backup_path)

    # Write updated config (clean JSON, 4-space indent matching original style)
    with open(CONFIG_PATH, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")

    return backup_path


def main():
    if len(sys.argv) < 2:
        print("Usage: de_mavlink_config_helper.py {read|write <json>}", file=sys.stderr)
        sys.exit(1)

    action = sys.argv[1]

    if action == "read":
        try:
            result = read_config()
            print(json.dumps(result, indent=2))
        except Exception as e:
            print(f"ERROR reading config: {e}", file=sys.stderr)
            sys.exit(1)

    elif action == "write":
        if len(sys.argv) < 3:
            print("ERROR: write requires a JSON argument", file=sys.stderr)
            sys.exit(1)
        try:
            updates = json.loads(sys.argv[2])
            backup = write_config(updates)
            print(f"OK: config updated. Backup saved to {backup}")
        except Exception as e:
            print(f"ERROR writing config: {e}", file=sys.stderr)
            sys.exit(1)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
