GPIO_TRIG = 4
GPIO_ECHO = 3
AVG_COUNT = 3

gpio.mode(GPIO_TRIG, gpio.OUTPUT)
gpio.mode(GPIO_ECHO, gpio.INT)
time_start = 0
time_end = 0

function echo_cb(level)
  if level == 1 then
    time_start = tmr.now()
    gpio.trig(GPIO_ECHO, "down")
  else
    time_end = tmr.now()
  end
end

function measure()
  gpio.trig(GPIO_ECHO, "up", echo_cb)
  gpio.write(GPIO_TRIG, gpio.HIGH)
  tmr.delay(100)
  gpio.write(GPIO_TRIG, gpio.LOW)
  tmr.delay(100000)
  if (time_end - time_start) < 0 then
    return -1
  end
  return ((time_end - time_start) * 10) / 58
end

function measure_avg()
  if measure() < 0 then  -- drop the first sample
    return -1 -- if the first sample is invalid, return -1
  end
  avg = 0
  for cnt = 1, AVG_COUNT do
    distance = measure()
    if distance < 0 then
      return -1 -- return -1 if any of the meas fails
    end
    avg = avg + distance
    tmr.delay(30000)
  end
  return avg / AVG_COUNT
end


tmr.alarm(0, 1000, 1, function() 
  measured = measure_avg()
  if measured < 0 then
    print("NA")
  else
    m = measured / 1000
    mm = measured % 1000
    print(m.."."..mm.."m")
  end
end)
