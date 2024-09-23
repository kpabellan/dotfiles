#!/usr/bin/env python3

import requests
import datetime
import json

latitude = 37.6485
longitude = 118.9721
units = 'imperial'
api_key = '' # Insert your OpenWeatherMap API key here

ICON_MAP = {
    "01d": "", "01n": "", "02d": "", "02n": "",
    "03d": "", "03n": "", "04d": "", "04n": "",
    "09d": "", "09n": "", "10d": "", "10n": "",
    "11d": "", "11n": "", "13d": "", "13n": "",
    "50d": "", "50n": ""
}

def unix_to_date(unix):
    return datetime.datetime.fromtimestamp(unix).strftime('%m/%d/%Y')

def unix_to_time(unix):
    return datetime.datetime.fromtimestamp(unix).strftime('%I:%M %p')

def get_icon(icon):
    return ICON_MAP.get(icon, "?")

def get_moon_icon(moon_phase):
    if moon_phase == 0 or moon_phase == 1:
        return ""  # New Moon (nf-weather-moon_new)
    elif 0 < moon_phase < 0.125:
        return ""  # Waxing Crescent (start) (nf-weather-moon_waxing_crescent_1)
    elif 0.125 <= moon_phase < 0.25:
        return ""  # Waxing Crescent (end) (nf-weather-moon_waxing_crescent_2)
    elif moon_phase == 0.25:
        return ""  # First Quarter (nf-weather-moon_first_quarter)
    elif 0.25 < moon_phase < 0.375:
        return ""  # Waxing Gibbous (start) (nf-weather-moon_waxing_gibbous_1)
    elif 0.375 <= moon_phase < 0.5:
        return ""  # Waxing Gibbous (end) (nf-weather-moon_waxing_gibbous_2)
    elif moon_phase == 0.5:
        return ""  # Full Moon (nf-weather-moon_full)
    elif 0.5 < moon_phase < 0.625:
        return ""  # Waning Gibbous (start) (nf-weather-moon_waning_gibbous_1)
    elif 0.625 <= moon_phase < 0.75:
        return ""  # Waning Gibbous (end) (nf-weather-moon_waning_gibbous_2)
    elif moon_phase == 0.75:
        return ""  # Last Quarter (nf-weather-moon_third_quarter)
    elif 0.75 < moon_phase < 0.875:
        return ""  # Waning Crescent (start) (nf-weather-moon_waning_crescent_1)
    elif 0.875 <= moon_phase < 1:
        return ""  # Waning Crescent (end) (nf-weather-moon_waning_crescent_2)

def get_weather_data():
    r = requests.get(f"https://api.openweathermap.org/data/3.0/onecall?lat={latitude}&lon={longitude}&exclude=minutely,hourly,alerts&units={units}&appid={api_key}")
    weather_data = r.json()

    # Current weather
    current_weather = weather_data["current"]
    current_temp = current_weather["temp"]
    current_feels_like = current_weather["feels_like"]
    current_icon = get_icon(current_weather["weather"][0]["icon"])
    current_description = current_weather["weather"][0]["description"]

    # Daily forecast for the next 5 days
    daily_forecasts = weather_data["daily"][:5]  # Get the next 5 days
    forecast_text = "5-Day Forecast:\n"

    for day in daily_forecasts:
        date = unix_to_date(day["dt"])
        day_icon = get_icon(day["weather"][0]["icon"])
        temp_max = day["temp"]["max"]
        temp_min = day["temp"]["min"]
        description = day["weather"][0]["description"].capitalize()
        sunrise = unix_to_time(day["sunrise"])
        sunset = unix_to_time(day["sunset"])
        moonphase = get_moon_icon(day["moon_phase"])

        forecast_text += (f"{date}: {day_icon} {temp_max:.0f}°F / {temp_min:.0f}°F {description}\n"
                          f"Sunrise: {sunrise}\n"
                          f"Sunset: {sunset}\n"
                          f"Moon phase: {moonphase}")
        
        if day != daily_forecasts[-1]:
            forecast_text += "\n\n"

    # Format for Waybar output
    return {
        "text": f"{current_icon} {current_temp:.0f}°F",
        "tooltip": (f"Current Weather:\n"
                    f"Temperature: {current_temp:.0f}°F\n"
                    f"Feels like: {current_feels_like:.0f}°F\n"
                    f"Description: {current_description.capitalize()}\n\n"
                    f"{forecast_text}"),
        "class": "weather"
    }

if __name__ == "__main__":
    weather_info = get_weather_data()
    print(json.dumps(weather_info))
