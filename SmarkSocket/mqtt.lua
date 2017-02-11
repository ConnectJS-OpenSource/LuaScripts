
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
            gpio_actions(5,"output","low")
        end,
    ["dev1000_atmega328_switchoff"] = function() 
            gpio_actions(8,"output","low")
            gpio_actions(5,"output","high")
        end,
}

init = function(clientid,ping)
    local pin=8
    gpio.mode(pin, gpio.OUTPUT)
    m = mqtt.Client(clientid, ping, "connectjs","Atmega328")
    m:lwt("server", "offline", 0, 0)
    m:on("offline", function(client)
            print ("offline") 
            gpio_actions(7,"output","high")
            tmr.alarm(1,10000,1, function()
                init("ESP_CONNECTJS_DEV1000",60)
            end)
        end)
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
        pcall(function() actions[data]() end)
      end
      if data ~= nil then
        actions["print"](topic.."- "..data)
      end
    end)
    m:connect("192.168.1.106", 1883, 0, 0 , function(client)
        gpio_actions(7,"output","low")
        tmr.stop(1)
        print("Connected to RasberryPi MQTT Exchange")
        m:subscribe({["DEV1000"]=0, ["DEV1000/cmd"]=0}, function(client) print("Subscription Added") end)
        m:publish("server",clientid.." Online",0,0)
    end, 
    function(client, reason)
        gpio_actions(7,"output","high")
        print("failed reason: "..reason)
    end)
end

init("ESP_CONNECTJS_DEV1000",60)
