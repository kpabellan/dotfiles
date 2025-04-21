#!/usr/bin/env python3

import subprocess
import json

def get_wifi_signal_strength():
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode == 0:
            lines = result.stdout.strip().splitlines()
            for line in lines:
                active, ssid, signal = (line.split(":") + [""] * 3)[:3]
                if active == "yes":
                    return int(signal)
    except Exception:
        pass

def get_vpn_status():
    try:
        result = subprocess.run(
            ["mullvad", "status"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode != 0:
            return "VPN: Not connected"

        output = result.stdout.strip()

        if "Disconnected" in output:
            return "VPN: Not connected"
        elif "Connecting" in output:
            return "VPN: Connecting"
        else:
            relay = None
            location = None
            for line in output.splitlines():
                line = line.strip()
                if line.startswith("Relay:"):
                    relay = line.split(":", 1)[1].strip()
                elif line.startswith("Visible location:"):
                    location = line.split(":", 1)[1].split(".")[0].strip()
            if relay and location:
                return f"VPN: Connected\nLocation: {location}"
            else:
                return "VPN: Connected\nDetails: Unknown"
    except Exception:
        pass

def get_network_status():
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        if result.returncode != 0:
            return {
                "text": "󰖪 ",
                "tooltip": "No connection",
                "class": "disconnected"
            }

        lines = result.stdout.strip().splitlines()
        for line in lines:
            device, dev_type, state, connection = (line.split(":") + [""] * 4)[:4]
            if state.lower() == "connected":
                vpn_status = get_vpn_status()
                if dev_type == "wifi":
                    signal_strength = get_wifi_signal_strength()
                    if signal_strength is not None:
                        return {
                            "text": "󰖩 ",
                            "tooltip": f"SSID: {connection} ({signal_strength}%)\n{vpn_status}",
                            "class": "connected"
                        }
                    else:
                        return {
                            "text": "󰖪 ",
                            "tooltip": f"SSID: {connection}\n{vpn_status}",
                            "class": "connected"
                        }
                elif dev_type == "ethernet":
                    return {
                        "text": "󰈀 ",
                        "tooltip": f"SSID: {connection}\n{vpn_status}",
                        "class": "connected"
                    }
        return {
            "text": "󰖪 ",
            "tooltip": "No connection\nVPN: Not connected",
            "class": "disconnected"
        }
    except Exception:
        pass

if __name__ == "__main__":
    network_status = get_network_status()
    print(json.dumps(network_status))
