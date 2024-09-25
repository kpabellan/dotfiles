#!/bin/bash

player_name=$(playerctl -p spotify status 2>/dev/null)

current_song=$(playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null)

if [ -z "$current_song" ]; then
    current_song="No song playing"
fi

if [ "$player_name" = "Playing" ] || [ "$player_name" = "Paused" ]; then
    spotify_logo="󰓇 "
    current_song="$spotify_logo$current_song"
fi

echo "$current_song"
