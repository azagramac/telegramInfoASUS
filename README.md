[![License](https://img.shields.io/github/license/AzagraMac/telegramInfoASUS.svg?style=for-the-badge&color=yellow)](LICENSE) <a href="https://www.paypal.com/paypalme/azagramac" target="_blank"><img src="https://www.nopcommerce.com/images/thumbs/0005707_paypalme-payment-method.png" alt="Buy Me A Coffee" style="height: 28px !important;" align="right" /></a><br/>

### Requirement
You have an ASUS router compatible with [firmware merlin](https://www.asuswrt-merlin.net).
List supported devices: https://github.com/RMerl/asuswrt-merlin.ng/wiki/Supported-Devices

### Tested
On Asus RT-AX88U Pro with merlin firmware version [388.3_0](https://onedrive.live.com/?authkey=%21AJLLKAY%2D%2D4EBqDo&id=CCE5625ED3599CE0%2121144&cid=CCE5625ED3599CE0)

### Install
- You need a telegram token, you can apply for one at https://t.me/BotFather, and the Chat ID, you can request it at https://t.me/myidbot
- Edit telegram.env file with your credentials
- Copy file telegram.env to `/jffs/`
- Copy script `/jffs/scripts/`

### Capture
![image](https://github.com/AzagraMac/botTelegramASUS/assets/571796/7fb762bd-5513-45ed-92dc-daa15c59713c)

### Cron job
`cru a status "0 */2 * * * /jffs/scripts/status.sh"`

#### Thanks
[@juanrs_05](https://twitter.com/juanrs_05) and [@RMerlinDev](https://twitter.com/RMerlinDev)
