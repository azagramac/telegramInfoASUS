#!/bin/sh

#
# Dev: AzagraMac | 2023
# Link: https://azagramac.gitbook.io/
#

# Unset vars
unset $IP_PWAN0
unset $IP_DNS1
unset $IP_DNS2
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

IP_WAN0=$(nvram get wan0_ipaddr)
IP_LAN=$(nvram get lan_ipaddr)
IP_DNS1=$(nvram get wan_dns1_x)
IP_DNS2=$(nvram get wan_dns2_x)

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

## Telegram
TELEGRAM_AUTH="/jffs/telegram.env"
TOKEN=$(cat $TELEGRAM_AUTH | grep "TOKEN" | awk -F "=" '{print $2}')
CHATID=$(cat $TELEGRAM_AUTH | grep "CHAT_ID" | awk -F "=" '{print $2}')
API_TELEGRAM="https://api.telegram.org/bot$TOKEN/sendMessage?parse_mode=HTML"

DATE=$(date +"%T, %d/%m/%Y")
LIMIT_TEMP_CPU=70
unset $BANNER

if [ "$TEMP_CPU" -gt "$LIMIT_TEMP_CPU" ]
then
    BANNER="🔥 $MODEL_NAME | CPU: $TEMP_CPUº 🔥"
    curl -s -X POST $API_TELEGRAM \
        -d chat_id=$CHATID \
        -d text="$(printf "<b>$BANNER</b>\n\n \
        <b>Information</b>\n \
        - Model: $MODEL_NAME\n \
        - Firmware: $FIRMWARE_VERSION\n \
        - SSID WiFi 2.4Ghz: $SSID_24GHZ\n \
        - SSID WiFi 5Ghz: $SSID_5GHZ\n\n \
        <b>Temperatures</b>\n \
        * CPU: $TEMP_CPUº\n \
        * WiFi 2.4Ghz: $TEMP_WIFI24º\n \
        * WiFi 5Ghz: $TEMP_WIFI5º\n\n \
        <b>Monitor</b>\n \
        * Load CPU (1m/5m/15m):\n \
        \t\t$CPU_USED_1M / $CPU_USED_5M / $CPU_USED_15M\n \
        * RAM Used: $RAM_USED_PERCENTAGE%%\n \
        * Swap Used: $SWAP_USED%%\n\n \
        <b>Network</b>\n \
        * WAN: $IP_WAN0\n \
        * DNS 1: $IP_DNS1\n \
        * DNS 2: $IP_DNS2\n \
        * LAN: $IP_LAN\n")" > /dev/null 2>&1
else
    BANNER="❄️ $MODEL_NAME | CPU: $TEMP_CPUº ❄️"
    curl -s -X POST $API_TELEGRAM \
        -d chat_id=$CHATID \
        -d text="$(printf "<b>$BANNER</b>\n\n \
        <b>Information</b>\n \
        - Model: $MODEL_NAME\n \
        - Firmware: $FIRMWARE_VERSION\n \
        - SSID WiFi 2.4Ghz: $SSID_24GHZ\n \
        - SSID WiFi 5Ghz: $SSID_5GHZ\n\n \
        <b>Temperatures</b>\n \
        * CPU: $TEMP_CPUº\n \
        * WiFi 2.4Ghz: $TEMP_WIFI24º\n \
        * WiFi 5Ghz: $TEMP_WIFI5º\n\n \
        <b>Monitor</b>\n \
        * Load CPU (1m/5m/15m):\n \
        \t\t$CPU_USED_1M / $CPU_USED_5M / $CPU_USED_15M\n \
        * RAM Used: $RAM_USED_PERCENTAGE%%\n \
        * Swap Used: $SWAP_USED%%\n\n \
        <b>Network</b>\n \
        * WAN: $IP_WAN0\n \
        * DNS 1: $IP_DNS1\n \
        * DNS 2: $IP_DNS2\n \
        * LAN: $IP_LAN\n")" > /dev/null 2>&1
fi
