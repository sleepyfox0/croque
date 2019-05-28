local timer = {}

timer.max = 0
timer.current = 0

function timer.set(s)
  timer.max = s
  timer.current = s
end

function timer.update(dt)
  timer.current = timer.current - dt
  if timer.current <= 0 then timer.current = 0 end
end

function timer.alarm()
  if timer.current <= 0 then
    return true
  end

  return false
end

function timer.getPercent()
  if timer.max > 0 and timer.current >= 0 then
    return (timer.current / timer.max)
  end
  return 0
end

function timer.getLeft()
  local minutes = math.floor(timer.current / 60)
  local seconds = math.floor(timer.current - (minutes*60))
  local str = string.format("%02d:%02d", minutes, seconds)
  return str
end

return timer
