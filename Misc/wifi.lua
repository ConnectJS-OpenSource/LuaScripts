print("WIFI control")
wifi.setmode(wifi.SOFTAP)
print("ESP8266 mode is: ".. wifi.getmode())
cfg={}
cfg.ssid="TBD_ESP"
cfg.pwd="Atmega328"
if ssid and password then
print("ESP8266 SSID is: ".. cfg.ssid .. "and PASSWORD is: ".. cfg.password)
end
wifi.ap.config(cfg)
print(wifi.ap.getmac())