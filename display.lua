
local display = {}

local PAUSE = "pause"
local DRAW = "draw"
local can = nil

display.pt = 5
display.dt = 60
display.timer = require "timer"
display.width = 0

function display.load(iu, imgr, dsize)
  display.width = dsize
  display.iu = iu
  display.rng = imgr
  display.next = nil
  can = love.graphics.newCanvas(dsize, dsize)
end

function display.set(files)
  display.f = files
  display.rng.setSet(files)
  display.state = PAUSE
  display.timer.set(display.pt)
end

function display.update(dt)
  display.timer.update(dt)
  if display.timer.alarm() then
    if display.state == PAUSE then
      local file = display.rng.next()
      --display._setNext(file)
      local ecnt = 0
      while not pcall(display._setNext, file) do
        file = display.rng.next()
        ecnt = ecnt + 1
        if ecnt > 10 then
          error("Cannot read image data")
        end
      end
      display.iu.applyImage(can, display.next)
      display.timer.set(display.dt)
      display.state = DRAW
    else
      display.timer.set(display.pt)
      display.state = PAUSE
    end
  end
end

function display.draw()
  if display.state == DRAW then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(can, 0, 8)
    local time = display.timer.getLeft()
    love.graphics.print(time, 5, 0)
    time = display.timer.getPercent()
    time = math.floor(time * (display.width - 40))
    love.graphics.setColor(229/255,  86/255,  86/255)
    love.graphics.rectangle("fill", 48, 0, time, 8)
  else
    love.graphics.setColor(1, 1, 1)
    local time = display.timer.getLeft()
    love.graphics.print(time, 5, 0)
    time = 1 - display.timer.getPercent()
    time = math.floor(time * (display.width - 40))
    love.graphics.setColor(82/255,  75/255, 163/255)
    love.graphics.rectangle("fill", 48, 0, time, 8)
  end
end

function display.space()
  display.timer.current = 0
end

function display._setNext(f)
  display.next = love.graphics.newImage(f)
end

return display
