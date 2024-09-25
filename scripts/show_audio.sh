#!/bin/bash

spotify_status=$(playerctl -p spotify status 2>/dev/null)

if [ "$spotify_status" = "Playing" ] || [ "$spotify_status" = "Paused" ]; then
    spotify_logo="󰓇 "
    current_song=$(playerctl -p spotify metadata --format "{{ title }}" 2>/dev/null)
    artist=$(playerctl -p spotify metadata --format "{{ artist }}" 2>/dev/null)
    echo "$spotify_logo$current_song - $artist"
    exit 0
fi

other_player_status=$(playerctl status 2>/dev/null)

if [ "$other_player_status" = "Playing" ] || [ "$other_player_status" = "Paused" ]; then
    current_song=$(playerctl metadata --format "  {{ title }}" 2>/dev/null)
    echo "$current_song"
    exit 0
fi