sv = net.createServer(net.TCP, 30)
function receiver(sck, data)
  sck:send("Smart Wifi Solution Server Online")
  sck:close()
end

if sv then
  sv:listen(80, function(conn)
    conn:on("receive", receiver)
  end)
end