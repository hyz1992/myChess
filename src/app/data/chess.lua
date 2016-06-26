Chess = class("Chess")
ChessTag = {
	JU 		= 1,
	MA 		= 2,
	XIANG 	= 3,
	SHI		= 4,
	JIANG	= 5,
	PAO		= 6,
	BING	= 7,
}

ChessColor = {
	NONE 	= 0,
	RED 	= 1,
	BLACK 	= 2,
}

g_myColor = ChessColor.RED

function Chess:ctor( ... )
	addProperty(Chess,"id",0)
	addProperty(Chess,"posId",0)
	addProperty(Chess,"chessId",0)
	addProperty(Chess,"chessTag",0)
	addProperty(Chess,"color",0)
	addProperty(Chess,"isDead",0)
	addProperty(Chess,"moveable",0)
end

function Chess:getIsMyChess()
	return self:getColor()==g_myColor
end

-- function init(_posId,_chessId,_chessTag,_color,_isDead)
-- 	_posId = posId
-- 	_chessId = chessId
-- 	_chessTag = chessTag
-- 	_color = color
-- 	_isDead = isDead
-- end

return Chess