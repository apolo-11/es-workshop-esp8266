tmr.alarm(0,1000,1,function() 
  if wifi.sta.getip() ~= nil then
    tmr.stop(0)
    print("WiFi Connect OK")
    dofile("temperature.lc")
  else
    print("Waiting for WiFi...")
  end
end)

