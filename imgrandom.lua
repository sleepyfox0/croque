
local imgr = {}

imgr.rng = love.math.newRandomGenerator()
imgr.set = nil
imgr.idx = -1

function imgr.setSet(s)
  imgr.set = s
  imgr._shuffle()
  imgr.idx = 0
end

function imgr._shuffle()
  for i, v in ipairs(imgr.set) do
    local j = imgr.rng:random(i, #imgr.set)
    imgr._swap(i, j)
  end
end

function imgr._swap(i, j)
  local tmp = imgr.set[j]
  imgr.set[j] = imgr.set[i]
  imgr.set[i] = tmp
end

function imgr.next()
  if imgr.set then
    imgr.idx = imgr.idx + 1
    if imgr.idx > #imgr.set then
      imgr._shuffle()
      imgr.idx = 1
    end
    return imgr.set[imgr.idx]
  end
end

function imgr.update()
  imgr.rng:random()
end

return imgr
