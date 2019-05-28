-- DEBUG
-- Directory dropped while displaying stuff

local con = require "lovecon/console"

local consoleopen = true

local iu = require "imageutils"
local irand = require "imgrandom"

local disp = require "display"

local cc = nil
local zoomX = 0
local zoomY = 0

local WIDTH = 80
local HEIGHT = 30

local mounted = false
local fpath = ""
local files = {}

local dsize = 800

local fnt = love.graphics.newImageFont("Chroma48.png",
                  "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ",
                  0)

function love.load()
  love.keyboard.setKeyRepeat(true)
  local w, h = love.window.getDesktopDimensions(1)
  if h < 800 then
    dsize = 600
  end
  if h < 400 then
    dsize = 400
  end

  iu.dsize = dsize

  con.init(WIDTH, HEIGHT)
  con.isDebug = false
  con.background  = {220/255, 172/255, 108/255}
  con.outc        = { 31/255,  30/255,  35/255}
  con.errc        = {229/255,  86/255,  86/255}
  con.debugc      = {106/255, 146/255,  84/255}
  con.fnt = fnt

  cc = love.graphics.newCanvas(WIDTH*8, HEIGHT*8)
  zoomX = 640 / (WIDTH*8)
  zoomY = 480 / (HEIGHT*8)

  addCommands()

  printIntro()
  _onreturn()

  con.enable(true)

  disp.load(iu, irand, dsize)
end

function love.update(dt)
  disp.rng.update(dt)
  if consoleopen then
    con.update(dt)
  else
    local stat, err = pcall(disp.update, dt)
    if not stat then
      love.window.setMode(640, 480)
      consoleopen = true
      con.error("Unable to read images. Please get others")
      con.enable(true)
    end
  end
end

function love.draw()
  if consoleopen then
    love.graphics.setCanvas(cc)
    con.draw()
    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(cc, 0, 0, 0, zoomX, zoomY)
  else
    local oldfnt = love.graphics.getFont()
    love.graphics.setFont(fnt)
    disp.draw()
    love.graphics.setFont(oldfnt)
  end
end

function love.keypressed(key, scancode, isrepeat)
  con.keypressed(key, scancode, isrepeat)
  if not consoleopen and key == 'escape' then
    love.window.setMode(640, 480)
    consoleopen = true
    con.enable(true)
  elseif not consoleopen and key == 'space' then
    disp.space()
  end
end

function love.textinput(text)
  con.textinput(text)
end

function love.directorydropped(path)
  if not con.isEnabled then
    return
  end
  con.debug("Dropped " .. path)
  if mounted then
    love.filesystem.unmount(fpath)
    con.debug("Unmounted " .. fpath)
    mounted = false
  end

  fpath = path
  mounted = love.filesystem.mount(fpath, "folder")
  if mounted then
    con.debug(path .. " successfully mounted!")
    con.print("Read in " .. path)
    files = iu.getImages()
    for _, v in ipairs(files) do
      con.debug("  " .. v)
    end
    if #files == 0 then
      con.print("The selected folder is empty. Please select another one.")
    end
  end
end

function addCommands()
  con.onreturn = _onreturn
  con.addCommand("help", _help)
  con.addCommand("set", _set)
  con.addCommand("list", _list)
  con.addCommand("run", _run)
  con.addCommand("exit", _exit)
end

function _help()
  con.print("The following commands are available:")
  con.print("  help")
  con.print("  set")
  con.print("    timer")
  con.print("    pause")
  con.print("  list")
  con.print("  run")
  con.print("  exit")
end

function _list()
  for _, v in ipairs(files) do
    con.print("- " .. v)
  end
end

function _run()
  if #files == 0 then
    con.print("No files to run. Please select a different directory.")
    return
  end

  con.debug("Load files into the display")
  disp.set(files)
  con.debug("switch context to display")
  con.enable(false)
  consoleopen = false
  love.window.setMode(dsize+8, dsize)
end

function _set(args)
  if #args ~= 2 then
    con.print("Wrong number of arguments.")
    con.print("Use either 'timer' or 'pause' and set the seconds")
    return
  end
  if args[1] == "timer" then
    __timer(args)
  elseif args[1] == "pause" then
    __pause(args)
  else
    con.print("The system cannot set " .. args[1])
  end
end

function __timer(args)
  local seconds = tonumber(args[2])
  con.print("Setting timer to " .. seconds .. " seconds.")
  disp.dt = seconds
end

function __pause(args)
  local seconds = tonumber(args[2])
  con.print("Setting pause to " .. seconds .. " seconds.")
  disp.pt = seconds
end

function __filter(args)
  con.print("Setting filter to " .. args[2])
end

function _exit()
  love.event.quit(0)
end

function _onreturn()
  con.print("")
  con.print("ready")
end

function printIntro()
  con.print("Welcome to the Croque drawing trainer. To start training just drop a folder intothe window and enter 'run'.")
  con.print("")
  con.print("Alternatively configure the system with this console. To see a list of availablecommands just type in 'help'.")
  con.print("")
  con.print("To skip the current displayed image press the space key. To return to this menu press escape.")
end
