
local console = {}

local utils = require "lovecon/utils"

console._max = 2048
console._blink = false
console._bt = 0
console._cx = 0
console._commands = {}
console._history = {}
console._hidx = 1

console.isDebug = true

console.w = 0
console.h = 0

console.fnt = nil
console.canvas = nil

console.background  = {  0/255,   0/255,   0/255}
console.outc        = {255/255, 255/255, 255/255}
console.errc        = {204/255,  53/255,   0/255}
console.debugc      = { 94/255, 200/255,   9/255}

console.q = {}
console.c = {}

console.input = ""

console.y = 0
console.line = 0
console.isEnabled = false

console.onreturn = nil

function console.init(w, h)
  w = w or 40
  h = h or 30

  console.w = w
  console.h = h

  console.fnt = love.graphics.newImageFont("lovecon/VictoriaBold.png",
                    "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ",
                    0)
end

function console.enable(b)
  console.isEnabled = b
end

function console.addCommand(name, fun)
  console._commands[name] = fun
end

function console.clear()
  console.q = {}
  console.c = {}
  console.line = 0
end

function console.print(msg)
  console.addMessage(msg, console.outc)
end

function console.error(msg)
  console.addMessage(msg, console.errc)
end

function console.debug(msg)
  if console.isDebug then
    console.addMessage(msg, console.debugc)
  end
end

function console.addMessage(msg, c)
  local sl = msg:len()
  if sl > console.w then
    local msg1 = msg:sub(1, console.w)
    local msg2 = msg:sub(console.w + 1)
    console.addMessage(msg1, c)
    console.addMessage(msg2, c)
  else
    table.insert(console.q, msg)
    table.insert(console.c, c)
    console.line = console.line + 1
  end

  if #console.q > console._max then
    console._collapse()
  end
end

function console.update(dt)
  console._bt = console._bt + dt
  if console._bt > 0.5 then
    console._blink = not console._blink
    console._bt = console._bt - 0.5
  end
end

function console.draw()
  local msg = "> " .. console.input
  console.y = console.line
  if console.isEnabled then
    console.y = console.line + math.floor(msg:len() / console.w) + 1
  end

  local width = console.w * 8
  local height = console.h * 8
  love.graphics.setColor(console.background)
  love.graphics.rectangle("fill", 0, 0, width, height)

  local fnt = love.graphics.getFont()
  love.graphics.setFont(console.fnt)

  local startidx = math.max(0, (console.y - console.h))
  local y = 0
  for i = startidx+1, #console.q do
    local v = console.q[i]
    love.graphics.setColor(console.c[i])
    love.graphics.print(v, 0, y-1)
    y = y + 8
  end

  local cursor = math.floor(y / 8)
  if console.isEnabled then
    love.graphics.setColor(console.outc)
    while(msg:len() > console.w) do
      local msgtmp = msg:sub(1, console.w)
      love.graphics.print(msgtmp, 0, y-1)
      y = y + 8
      msg = msg:sub(console.w + 1)
    end
    love.graphics.print(msg, 0, y-1)

    if console._blink then
      local cy = math.floor(console._cx / console.w) + cursor
      local cx = math.floor((console._cx + 2) % console.w)
      cy = cy * 8
      cx = cx * 8
      love.graphics.setColor(console.outc)
      love.graphics.rectangle("fill",cx , cy, 8, 8)

      love.graphics.setColor(console.background)
      local chr = console.input:sub(console._cx+1, console._cx+1)
      if chr then
        love.graphics.print(chr, cx, cy-1)
      end
    end
  end

  love.graphics.setFont(fnt)
end

function console.keypressed(key, scancode, isrepeat)
  if key == "backspace" then
    if console._cx > 0 then
      console.input = console.input:sub(1, console._cx-1) .. console.input:sub(console._cx + 1, #console.input)
      console._cx = console._cx - 1
    end
  elseif key == "delete" then
    if console._cx < #console.input then
      console.input = console.input:sub(1, console._cx) .. console.input:sub(console._cx + 2, #console.input)
    end
  elseif key == "return" or key == "kpenter" then
    console.print("> " .. console.input)
    if console.input:len() > 0 then
      table.insert(console._history, console.input)
      if console._hidx + 1 < #console._history then
        console._deleteHistory()
      end
      console._hidx = #console._history
    end

    commands = utils.stringsplit(console.input)
    console._execute(commands)

    console.input = ""
    console._cx = 0
    if console.onreturn then
      console.onreturn()
    end
  elseif key == "left" then
    console._cx = console._cx - 1
    if console._cx < 0 then console._cx = 0 end
  elseif key == "right" then
    console._cx = console._cx + 1
    if console._cx > console.input:len() then console._cx = console.input:len() end
  elseif key == "up" then
    console._hidx = console._hidx - 1
    if console._hidx < 0 then console._hidx = 0 end
    console._setHistory()
  elseif key == "down" then
    console._hidx = console._hidx + 1
    local l = #console._history
    if console._hidx > l then console._hidx = l end
    console._setHistory()
  end
end

function console._setHistory()
  local idx = console._hidx + 1
  if idx > #console._history then
    console.input = ""
    return
  end
  local str = console._history[idx]
  console.input = str
end

function console._deleteHistory()
  local idx = console._hidx + 1
  table.remove(console._history, idx)
end

function console.textinput(text)
  if not console.isEnabled then
    return
  end

  console.input = console.input:sub(1, console._cx) .. text .. console.input:sub(console._cx + 1, #console.input)
  console._cx = console._cx + text:len()
end

function console._collapse()
  local q = {}
  local c = {}
  local start = #console.q - 31

  for i=1,30 do
    q[i] = console.q[start + i]
    c[i] = console.c[start + i]
  end

  console.line = 30
  console.q = q
  console.c = c
end

function console._execute(commands)
  if #commands == 0 then
    console.print("No command entered.")
    return
  end

  local cmd = commands[1]
  local args = {}
  for i = 2, #commands do
    table.insert(args, commands[i])
  end

  local prog = console._commands[cmd]
  if prog then
    local state, err = pcall(prog, args)
    if not state then
      console.error("Encountered an error while executing.")
      console.error(err)
    end
  else
    console.print("Command: \"" .. cmd .. "\" not found.")
  end
end

return console
