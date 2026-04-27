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
    return None


def get_vpn_status():
    vpns = []

    # Check Mullvad
    try:
        result = subprocess.run(
            ["mullvad", "status"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode == 0:
            output = result.stdout.strip()
            if "Connected" in output and "Disconnected" not in output:
                vpns.append(f"Mullvad: {output.splitlines()[0]}")
            elif "Connecting" in output:
                vpns.append("Mullvad: Connecting")
    except FileNotFoundError:
        pass

    # Check Tailscale
    try:
        result = subprocess.run(
            ["tailscale", "status", "--json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode == 0:
            ts = json.loads(result.stdout)
            backend = ts.get("BackendState", "")
            if backend == "Running":
                exit_node = ts.get("ExitNodeStatus", None)
                if exit_node:
                    vpns.append("Tailscale: Connected (exit node)")
                else:
                    vpns.append("Tailscale: Connected (mesh only)")
            elif backend == "Starting":
                vpns.append("Tailscale: Connecting")
    except FileNotFoundError:
        pass

    if vpns:
        return "\n".join(vpns)
    else:
        return "VPN: Not connected"


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
                "class": "disconnected",
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
                            "class": "connected",
                        }
                    else:
                        return {
                            "text": "󰖩 ",
                            "tooltip": f"SSID: {connection}\n{vpn_status}",
                            "class": "connected",
                        }
                elif dev_type == "ethernet":
                    return {
                        "text": "󰈀 ",
                        "tooltip": f"Ethernet: {connection}\n{vpn_status}",
                        "class": "connected",
                    }

        return {
            "text": "󰖪 ",
            "tooltip": "No connection\nVPN: Not connected",
            "class": "disconnected",
        }
    except Exception:
        return {
            "text": "󰖪 ",
            "tooltip": "Error checking network",
            "class": "disconnected",
        }


if __name__ == "__main__":
    network_status = get_network_status()
    print(json.dumps(network_status))