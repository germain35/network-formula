test:
  file.line:
    - name: /etc/network/interfaces
    - mode: ensure
    - indent: False
    - after: 'iface wlan0'
    - content: '    wpa-conf /etc/wpa/wpa_wlan0.conf'
