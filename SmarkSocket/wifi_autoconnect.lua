wifi.setmode(wifi.STATION, true)
station_cfg={}
station_cfg.ssid="Boss2"
station_cfg.pwd="Atmega328"
station_cfg.save=true
station_cfg.auto=true
wifi.sta.config(station_cfg)