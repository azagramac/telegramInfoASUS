#!/bin/sh

#
# Dev: AzagraMac 2023
# version: 1.1
# Link: https://azagramac.gitbook.io/
#

# Unset vars
unset $IP_PWAN0
unset $IP_LAN
unset $FIRMWARE_VERSION
unset $MODEL_NAME
unset $SSID_5GHZ
unset $SSID_24GHZ
unset $TEMP_CPU
unset $TEMP_WIFI24
unset $TEMP_WIFI5
unset $RAM_TOTAL
unset $RAM_USED
unset $RAM_FREE
unset $RAM_USED_PERCENTAGE
unset $RAM_FREE_PERCENTAGE
unset $SWAP_USED
unset $CPU_USED_1M
unset $CPU_USED_5M
unset $CPU_USED_15M
unset $UPTIME
unset $SKYNET_VERSION
unset $IPS_BANNED
unset $IN_BLOCK
unset $OUT_BLOCK
unset $SIGN_DATE

IP_WAN0=$(nvram get wan0_ipaddr)
IP_LAN=$(nvram get lan_ipaddr)

FIRMWARE_VERSION=$(nvram get webs_state_info_am)
MODEL_NAME=$(nvram get wps_device_name)

SSID_5GHZ=$(nvram get wl1_ssid)
SSID_24GHZ=$(nvram get wl0_ssid)

TEMP_CPU=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{printf("%.0f\n", $1 / 1000) }')
TEMP_WIFI24=$(wl -i eth6 phy_tempsense | awk '{print $1 / 2 + 20}')
TEMP_WIFI5=$(wl -i eth7 phy_tempsense | awk '{print $1 / 2 + 20}')

RAM_TOTAL=$(free | grep -i mem | awk '{print $2}')
RAM_USED=$(free | grep -i mem | awk '{print $3}')
RAM_FREE=$(free | grep -i mem | awk '{print $4}')
RAM_USED_PERCENTAGE=$(free | grep Mem | awk '{ printf("%.2f", $3/$2 * 100.0) }')
RAM_FREE_PERCENTAGE=$(free | grep Mem | awk '{ printf("%.2f", $4/$2 * 100.0) }')
SWAP_USED=$(free | grep Swap | awk '{ printf("%.2f", $3/$2 * 100.0) }')

CPU_USED_1M=$(cat /proc/loadavg | awk '{print $1}')
CPU_USED_5M=$(cat /proc/loadavg | awk '{print $2}')
CPU_USED_15M=$(cat /proc/loadavg | awk '{print $3}')

UPTIME=$(uptime|sed 's/.*\([0-9]\+ days\), \([0-9]\+\):\([0-9]\+\).*/\1, \2 hours, \3 minutes/')

## Skynet, How to! https://azagramac.gitbook.io/myblog/asus-router/instalar-skynet
SKYNET_VERSION=$(cat /tmp/mnt/sda1/skynet/skynet.cfg | grep localver | awk -F "=" '{print $2}' | tr -d '"')
IPS_BANNED=$(cat /tmp/mnt/sda1/skynet/events.log | tail -1 | awk '{print $6}')
IN_BLOCK=$(cat /tmp/mnt/sda1/skynet/events.log | tail -1 | awk '{print $15}')
OUT_BLOCK=$(cat /tmp/mnt/sda1/skynet/events.log | tail -1 | awk '{print $18}')

## Sign Trend
SIGN_DATE=$(nvram get bwdpi_sig_ver)

## Telegram
TELEGRAM_AUTH="/jffs/telegram.env"
TOKEN=$(cat $TELEGRAM_AUTH | grep "TOKEN" | awk -F "=" '{print $2}')
CHATID=$(cat $TELEGRAM_AUTH | grep "CHAT_ID" | awk -F "=" '{print $2}')
API_TELEGRAM="https://api.telegram.org/bot$TOKEN/sendMessage?parse_mode=HTML"

DATE=$(date +"%T, %d/%m/%Y")
LIMIT_TEMP_CPU=70
unset $BANNER

function sendMessage()
{
    curl -s -X POST $API_TELEGRAM \
        -d chat_id=$CHATID \
        -d text="$(printf "<b>$BANNER</b>\n\n \
        📊 <b>Status</b>\n \
        - CPU Temp: $TEMP_CPUº\n \
        - WLAN 2.4 Temp: $TEMP_WIFI24º\n \
        - WLAN 5 Temp: $TEMP_WIFI5º\n \
        ---\n \
        - Uptime: $UPTIME\n \
        - Load CPU: $CPU_USED_1M / $CPU_USED_5M / $CPU_USED_15M\n \
        - RAM Used: $RAM_USED_PERCENTAGE%% / Free: $RAM_FREE_PERCENTAGE%%\n \
        - Swap Used: $SWAP_USED%%\n\n \
        🧱 <b>Skynet</b>\n \
        - Skynet: $SKYNET_VERSION\n \
        - IPs Banned: $IPS_BANNED\n \
        - Inbound Blocks: $IN_BLOCK\n \
        - Outbound Blocks: $OUT_BLOCK\n\n \
        📃 <b>Info</b>\n \
        - Model: $MODEL_NAME\n \
        - Firmware: $FIRMWARE_VERSION\n \
        - SSDID 2.4Ghz: $SSID_24GHZ\n \
        - SSDID 5Ghz: $SSID_5GHZ\n \
        - IP WAN: $IP_WAN0\n \
        - IP LAN: $IP_LAN\n \
        - Trend Micro sign: $SIGN_DATE\n")" > /dev/null 2>&1
}

if [ "$TEMP_CPU" -gt "$LIMIT_TEMP_CPU" ]
then
    BANNER="🔥 $MODEL_NAME | CPU: $TEMP_CPUº 🔥"
    sendMessage
else
    BANNER="❄️ $MODEL_NAME | CPU: $TEMP_CPUº ❄️"
    sendMessage
fi
