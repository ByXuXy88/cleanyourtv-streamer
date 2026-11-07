"""Manage the optional standby monitor on a single authorized Google TV device."""

import argparse
from pathlib import Path
import re
import subprocess


HELPER = "/data/local/tmp/cleanyourtv-standby.sh"
RUNNING = f"ps -A -o ARGS | grep -Fqx 'sh {HELPER}'"
START = (
    f"if ! {RUNNING}; then "
    f"toybox nohup setsid sh {HELPER} </dev/null >/dev/null 2>&1 & sleep 1; fi; {RUNNING}"
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True, help="Exact serial shown by adb devices")
    parser.add_argument("--adb", default="adb", help="ADB executable, if it is not in PATH")
    parser.add_argument("--experimental", action="store_true", help="Opt in to untested Chromecast 4K support")
    parser.add_argument("action", choices=("install", "inspect", "status", "start", "stop"))
    args = parser.parse_args()
    command = [args.adb, "-s", args.device]

    def adb(*words, **options):
        return subprocess.run(command + list(words), check=True, text=True, timeout=20, **options)

    try:
        if adb("get-state", capture_output=True).stdout.strip() != "device":
            parser.error("Connect and authorize this device in ADB first.")
        product = adb("shell", "getprop", "ro.product.device", capture_output=True).stdout.strip()
        api = adb("shell", "getprop", "ro.build.version.sdk", capture_output=True).stdout.strip()
        supported = product == "kirkwood" or (product == "sabrina" and args.experimental)
        if not supported or api != "34":
            parser.error(f"Expected a Google TV Streamer on Android 14, got {product} / API {api}.")

        if args.action == "install":
            source = Path(__file__).with_name("cleanyourtv-standby.sh")
            staged = HELPER + ".new"
            adb("push", str(source), staged)
            adb("shell", f"sh -n {staged} && chmod 700 {staged} && mv {staged} {HELPER}")
            print("Monitor copied. Use the RAM chip in CleanYourTV to activate it.")
        elif args.action == "inspect":
            adb("shell", "sh", HELPER, "--inspect")
        elif args.action == "status":
            result = adb("shell", f"{RUNNING} && echo running || echo stopped", capture_output=True)
            print(result.stdout.strip())
        elif args.action == "start":
            adb("shell", f"test -s {HELPER} && {{ {START}; }}")
            print("Monitor running. Enable standby cleanup in CleanYourTV if it is switched off.")
        else:
            processes = adb("shell", "ps -A -o PID,PGID,ARGS", capture_output=True).stdout
            pattern = rf"^\s*(\d+)\s+\1\s+sh {re.escape(HELPER)}\s*$"
            for line in processes.splitlines():
                match = re.fullmatch(pattern, line)
                if match and int(match[1]) > 1:
                    adb("shell", f"kill -TERM -- -{int(match[1])}")
            print("Monitor stopped.")
    except (OSError, subprocess.SubprocessError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
