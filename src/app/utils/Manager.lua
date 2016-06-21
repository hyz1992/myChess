local math = math

module("Manager")

--根据位置posId得到矩阵坐标，返回的矩阵坐标以左下角为原点
function getCoordinateByPosId(posId)
	if posId<1 or posId>90 then
		return
	end
	x = posId%9
	y = math.floor(posId/9) + 1
	if x==0 then 
		x = 9
		y = y - 1
	end

	return {x=x,y=y}
end

function getPosIdByCoordinate(coord)
	local posId = (coord.y-1)*9 + coord.x
	return posId
end