require("ds1820")

-- read the configuration
dofile("config.lc")

function sendData()
  tmr.wdclr()
  
  if (#tmpSensors <= 0) then
    return
  end

  local sensorID = table.remove(tmpSensors)
  local temp=ds1820.read(sensors[sensorID])

  if(temp == "NA") then
    print("No data for: "..sensorID)
    return
  end

  print("Sending temp: "..sensorID .. ": "..temp.." C")

  tmr.wdclr()
  http.get("http://api.thingspeak.com/update?key="..API_KEY.."&field1="..temp, nil, function(code, data)
    if (code < 0) then
      print("Restarting because of http error: "..code)
      node.restart()
    else
      print(code, data)
    end

    -- send data from next sensor
    node.task.post(sendData)
  end)
end

function sendDataForAll()
  print("Sending data for all sensors.")
  
  tmr.wdclr()
  
  local sensorID = nil
  local sensorAddr = nil
  
  for sensorID, sensorAddr in pairs(sensors) do
    table.insert(tmpSensors, sensorID)
  end

  -- send data for all sensors
  node.task.post(sendData)
end


ds1820.setup(GPIO_DS1820)
sensors=ds1820.addrs()
tmpSensors={}

tmr.alarm(0, SEND_PERIOD, 1, function() sendDataForAll() end )
sendDataForAll()

