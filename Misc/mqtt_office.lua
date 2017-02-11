
if m ~= nil then m:close() end

local _wifi = function()
    print("Re-Connecting Wifi")
    dofile("wifi_connect.lua")
end

tmr.alarm(0, 10000, tmr.ALARM_AUTO, function() 
    if wifi.sta.getip() == nil then
        wifi.sta.eventMonReg(wifi.STA_GOTIP, function() 
            init("ESP_CONNECTJS_DEV1000",60)
            wifi.sta.eventMonStop(1)
        end)
        wifi.sta.eventMonStart()
        _wifi()
    end
end)

function split(str,sep)
    local array = {}
    local reg = string.format("([^%s]+)",sep)
    for mem in string.gmatch(str,reg) do
        table.insert(array, mem)
    end
    return array
end

local gpio_actions = function(pin,mode,value)
        print(pin..","..mode..","..value)
        if mode == "output" then mode = gpio.OUTPUT end
        if mode == "input" then mode = gpio.INPUT end
        if value == "high" then value = gpio.HIGH end
        if value == "low" then value = gpio.LOW end
        print(pin..","..mode..","..value)
        gpio.mode(pin, mode)
        gpio.write(pin, value) 
        m:publish("server", "GPIO "..pin.." is "..value.." now" ,0,0)
    end

local actions = {
    ["gpio"] = gpio_actions,
    ["subscribe"] = function(sub_id) m:subscribe(sub_id,0, function(client) m:publish("server", "Subscribed to "..sub_id,0,0) end) end,
    ["reboot"] = function() node:restart() end,
    ["connect"] = function() dofile("wifi_connect.lua") end,
    ["disconnect"] = function() wifi.sta.disconnect() end,
    ["getip"] = function() m:publish("server", "IP - "..wifi.sta.getip() ,0,0) end,
    ["init"] = function() dofile("init.lua") end,
    ["print"] = function(x) print(x) end,
    ["dev1000_atmega328_switchon"] = function() 
            gpio_actions(8,"output","high")
            gpio_actions(7,"output","low")
        end,
    ["dev1000_atmega328_switchoff"] = function() 
            gpio_actions(8,"output","low")
            gpio_actions(7,"output","high")
        end,
}

init = function(clientid,ping)
    local pin=8
    gpio.mode(pin, gpio.OUTPUT)
    m = mqtt.Client(clientid, ping)
    m:lwt("server", "offline", 0, 0)
    m:on("offline", function(client) print ("offline") end)
    m:on("message", function(client, topic, data) 
      if data ~= nil and topic=="DEV1000/cmd" then
        data = data:lower()
        local s,e = string.find(data,"gpio")
        if s==1 and e==4 and table.getn(split(data,","))==4 then
            local gpio,pin,mode,value = string.match(data, "([^,]+),([^,]+),([^,]+),([^,]*)")
            actions[gpio](pin,mode,value)
            return
        end
        s,e = string.find(data,"subscribe")
        if s==1 and e==9 and table.getn(split(data,","))==2 then
            local action,sid = string.match(data, "([^,]+),([^,]+)")
            actions[action](sid)
            return
        end
        actions[data]()
      end
      if data ~= nil then
        actions["print"](topic.."- "..data)
      end
    end)
    
    m:connect("broker.mqttdashboard.com", 1883, 0, 0 , function(client)
        print("Connected to RasberryPi MQTT Exchange")
        gpio_actions(7,"output","low")
        m:subscribe({["DEV1000"]=0, ["DEV1000/cmd"]=0}, function(client) print("Subscription Added") end)
        m:publish("server",clientid.." Online",0,0)
    end, 
    function(client, reason)
        gpio_actions(7,"output","high")
        print("failed reason: "..reason)
        init("ESP_Client",60)
    end)
end

init("ESP_CONNECTJS_DEV1000",60)
