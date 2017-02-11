wifi.setmode(wifi.STATION, true)
station_cfg={}
--station_cfg.ssid="Boss4G"
station_cfg.ssid="Boss2"
station_cfg.pwd="Atmega328"
station_cfg.save=true
station_cfg.auto=true

listap = function(t)
    local ap={}
    ap.ssid=nil
    ap.rssi=nil
    print("")
    for bssid,v in pairs(t) do
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        if rssi ~= nil then rssi = 2 * (rssi + 100) end
        print(ssid..":"..rssi)
        if ssid=="Boss2" or ssid=="Boss4G" then
            if ap.ssid == nil then
                ap.ssid=ssid
                ap.rssi=rssi
            elseif ap.ssid ~= nil and rssi > ap.rssi then
                ap.ssid = ssid
                ap.rssi=rssi
            end
        end
    end
    return ap
end

scan_cfg = {}
scan_cfg.channel = 0
scan_cfg.show_hidden = 1
wifi.sta.getap(scan_cfg, 1,function(t)
    local ap = listap(t)
    station_cfg.ssid=ap.ssid
    wifi.sta.config(station_cfg)
end)
