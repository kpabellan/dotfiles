#!/usr/bin/env python3

import subprocess

def toggle_wifi():
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "WIFI", "radio"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode == 0:
            wifi_status = result.stdout.strip().lower()
            if wifi_status == "enabled":
                subprocess.run(["nmcli", "radio", "wifi", "off"])
            elif wifi_status == "disabled":
                subprocess.run(["nmcli", "radio", "wifi", "on"])
    except Exception:
        pass

toggle_wifi()
