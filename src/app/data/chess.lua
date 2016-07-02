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
	addProperty(Chess,"node",nil)
end

function Chess:getIsMyChess()
	return self:getColor()==g_myColor
end

function Chess:clone(chess)
	self:setId(chess:getId())
	self:setChessId(chess:getChessId())
	self:setPosId(chess:getPosId())
	self:setChessTag(chess:getChessTag())
	self:setIsDead(chess:getIsDead())
	self:setColor(chess:getColor())
end

function Chess:print()
	if self.isDead~=0 then
		return
	end
	print("\n 	--->Chess:")
	print("id       :  "..self.id)
	print("chessId  :  "..self.chessId)
	print("chessTag :  "..self.chessTag)
	print("posId    :  "..self.posId)
	print("color    :  "..self.color)
	print("moveable :  "..(self.moveable and "true" or "false"))
end

return Chess