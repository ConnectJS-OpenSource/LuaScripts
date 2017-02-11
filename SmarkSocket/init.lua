if wifi.sta.getip()==nil then
    dofile("wifi_autoconnect.lua")
else
    dofile("mqtt.lua")
end
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
    print("Connected to "..(station_cfg.ssid)..", IP - "..wifi.sta.getip()) 
    dofile("mqtt.lua")
end)
wifi.sta.eventMonStart()