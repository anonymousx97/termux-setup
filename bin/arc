#!/data/data/com.termux/files/usr/bin/bash
read -p 'Link or Magnet
> ' x
echo -e "${x}\n" >> /data/data/com.termux/files/home/.arc_history
echo
aria2c -d /sdcard/Download --console-log-level=warn --summary-interval=0 --seed-time=0 --file-allocation=none $x