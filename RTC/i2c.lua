

tmr.alarm(6, 1000, tmr.ALARM_AUTO, function() 
    rtc = require("ds3231")
-- ESP-01 GPIO Mapping
    gpio0, gpio2 = 6, 7
    rtc.init(gpio0, gpio2)
    second, minute, hour, day, date, month, year = rtc.getTime();
    print(string.format("Time & Date: %s:%s:%s %s/%s/%s", hour, minute, second, date, month, year))
end)

-- Don't forget to release it after use
rtc = nil
package.loaded["ds3231"]=nil