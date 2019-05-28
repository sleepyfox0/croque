local iu = {}

iu.supported = {}
iu.supported["bmp"] = true
--iu.supported["gif"] = true
iu.supported["jpg"] = true
iu.supported["jpe"] = true
iu.supported["jpeg"] = true
iu.supported["jp2"] = true
iu.supported["pcd"] = true
iu.supported["pcx"] = true
iu.supported["pic"] = true
iu.supported["png"] = true
iu.supported["raw"] = true
iu.supported["tga"] = true
iu.supported["tif"] = true

iu.dsize = 800

function iu.applyImage(canvas, img)
  local dsh = iu.dsize / 2
  local zoom = 1
  local x = 0
  local y = 0
  local wx = img:getWidth()
  local wy = img:getHeight()

  if wx > wy then
    zoom = iu.dsize / wx
    wx = iu.dsize
    wy = wy * zoom
  else
    zoom = iu.dsize / wy
    wy = iu.dsize
    wx = wx * zoom
  end

  x = dsh - (wx/2)
  y = dsh - (wy/2)

  love.graphics.setCanvas(canvas)

  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(img, x, y, 0, zoom)

  love.graphics.setCanvas()
end

function iu.getImages()
  local files = love.filesystem.getDirectoryItems("folder")
  local imgs = {}
  for i,v in ipairs(files) do
    if iu.isImage(v) then
      table.insert(imgs, "folder/" .. v)
    end
  end
  return imgs
end

function iu.isImage(filename)
  if love.filesystem.getInfo("folder/" .. filename, "file") then
    local splitted = iu._splitstr(filename, ".")
    if iu.supported[string.lower(splitted[#splitted])] then
      return filename
    end
  end

  return nil
end

function iu._splitstr(instr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(instr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

return iu
