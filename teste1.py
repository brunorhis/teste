#!/usr/bin/env python3
import subprocess
import time
from PIL import Image, ImageDraw, ImageFont
from waveshare_epd import epd2in13_V4

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True).decode().strip()
    except:
        return "?"

def get_ip():
    ip = run("hostname -I").split()
    return ip[0] if ip else "?"

def get_wifi():
    ssid = run("iwgetid -r")
    signal = run("iwconfig wlan0 | grep -o 'Signal level=[^ ]*' | cut -d= -f2")
    return ssid or "desconectado", signal or "?"

def scan_wifi():
    res = run("nmcli -f SSID,SIGNAL dev wifi | sed '1,1d' | head -5")
    if not res:
        return ["nenhuma rede"]
    return res.split("\n")

def get_load():
    return run("cut -d ' ' -f1 /proc/loadavg")

def get_uptime():
    return run("uptime -p")

def draw_screen():
    epd = epd2in13_V4.EPD()
    epd.init()
    epd.Clear()

    w = epd.width
    h = epd.height
    image = Image.new('1', (w, h), 255)
    draw = ImageDraw.Draw(image)

    font = ImageFont.load_default()

    ip = get_ip()
    ssid, signal = get_wifi()
    load = get_load()
    uptime = get_uptime()
    networks = scan_wifi()

    y = 0
    draw.text((5, y), f"Kali Status", font=font, fill=0); y += 12
    draw.text((5, y), f"IP: {ip}", font=font, fill=0); y += 12
    draw.text((5, y), f"WiFi: {ssid}", font=font, fill=0); y += 12
    draw.text((5, y), f"Sinal: {signal}", font=font, fill=0); y += 12
    draw.text((5, y), f"Load: {load}", font=font, fill=0); y += 12
    draw.text((5, y), f"{uptime}", font=font, fill=0); y += 14

    draw.text((5, y), "Redes próximas:", font=font, fill=0); y += 12

    for line in networks:
        draw.text((5, y), line[:25], font=font, fill=0)
        y += 12

    epd.display(epd.getbuffer(image))
    epd.sleep()

if __name__ == "__main__":
    while True:
        draw_screen()
        time.sleep(30)
