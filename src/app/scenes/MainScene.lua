
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
    display.addSpriteFrames("chessSheet.plist","chessSheet.png")

    display.newSprite("bg_1.jpg")
    	:addTo(self)
    	:pos(display.cx,display.cy)

    self.boardBg = display.newSprite("boardBg.png")
    	:addTo(self)
    	-- :align(display.CENTER_BOTTOM)
    	:pos(display.cx,display.cy)
    self.boardBg:scale(display.width/self.boardBg:getContentSize().width)

    self:initChess()
    self.isMyTurn = false
end

function MainScene:initChess()
	self.mChess = {}
	self.oChess = {}
	for i=1,16 do
		self.mChess[i] = setProxy(Chess.new())
		self.oChess[i] = setProxy(Chess.new())
	end
	local posArr = {1,2,3,4,5,6,7,8,9,20,26,28,30,32,34,36}
	local tagArr = {ChessTag.JU,ChessTag.MA,ChessTag.XAING,ChessTag.SHI,ChessTag.SHUAI,ChessTag.SHI,ChessTag.XAING,ChessTag.MA,ChessTag.JU,
						ChessTag.PAO,ChessTag.PAO,ChessTag.BING,ChessTag.BING,ChessTag.BING,ChessTag.BING,ChessTag.BING}
	for i=1,16 do
		local mychess = self.mChess[i]
		local myChessItem = display.newSprite("#ChessStyle_5_BA.png")
				:addTo(self)
		UIEx.bind(myChessItem,mychess,"id",function (value)
			local posId = posArr[i]
			mychess:setPosId(posId)
			mychess:setChessId(100+posId)
			mychess:setColor(ChessColor.RED)
			myChessItem:pos(self:getPostionByPosId(posId).x,self:getPostionByPosId(posId).y)
			-- display.newTTFLabel({size = 20,color = cc.c3b(0,255,255),text = "p:"..posId})
			-- 	:addTo(myChessItem)
			-- 	:pos(35,35)

		end)
		UIEx.bind(myChessItem,mychess,"color",function (value)
			local chassTag = tagArr[i]
			myChessItem:setSpriteFrame(self:getImgPath(chassTag,value))
		end)
		UIEx.bind(myChessItem,mychess,"moveable",function (value)
			myChessItem:setTouchEnabled(value)
		end)
		
		myChessItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)			
			if event.name=="beagn" then

			elseif event.name == "moved" then
				myChessItem:pos(event.x,event.y)
	        elseif event.name == "ended" then
	        	local targetPosId = self:getPosIdByPosition({x = event.x,y = event.y})
	        	local targetPostion = self:getPostionByPosId(targetPosId)
	        	myChessItem:pos(targetPostion.x,targetPostion.y)
			end
			return true
		end)
		mychess:setId(i)
		mychess:setMoveable(true)
	end

	posArr = {82,83,84,85,86,87,88,89,90,65,71,55,57,59,61,63}
	for i=1,16 do
		local otchess = self.oChess[i]
		local otChessItem = display.newSprite("#ChessStyle_5_BA.png")
				:addTo(self)
		UIEx.bind(otChessItem,otchess,"id",function (value)
			local posId = posArr[i]
			otchess:setPosId(posId)
			otchess:setChessId(200+posId)
			otchess:setColor(ChessColor.BLACK)
			otChessItem:pos(self:getPostionByPosId(posId).x,self:getPostionByPosId(posId).y)
			-- display.newTTFLabel({size = 20,color = cc.c3b(255,255,0),text = "p:"..posId})
			-- 	:addTo(otChessItem)
			-- 	:pos(35,35)
		end)
		UIEx.bind(otChessItem,otchess,"color",function (value)
			local chassTag = tagArr[i]
			otChessItem:setSpriteFrame(self:getImgPath(chassTag,value))
		end)
		UIEx.bind(otChessItem,otchess,"moveable",function (value)
			otChessItem:setTouchEnabled(value)
		end)
		otChessItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)			
			if event.name=="beagn" then

			elseif event.name == "moved" then
				otChessItem:pos(event.x,event.y)
	        elseif event.name == "ended" then
	        	local targetPosId = self:getPosIdByPosition({x = event.x,y = event.y})
	        	local targetPostion = self:getPostionByPosId(targetPosId)
	        	otChessItem:pos(targetPostion.x,targetPostion.y)
			end
			return true
		end)

		otchess:setId(i)
		-- otchess:setMoveable(true)
	end
	
end

function MainScene:getImgPath(_chessTag,chessColor)
	local tagStr = "--"
	if _chessTag == ChessTag.JU then 			tagStr = "R"
	elseif _chessTag == ChessTag.MA then 		tagStr = "N"
	elseif _chessTag == ChessTag.XAING then 	tagStr = "B"
	elseif _chessTag == ChessTag.SHI then 		tagStr = "A"
	elseif _chessTag == ChessTag.SHUAI then 	tagStr = "K"
	elseif _chessTag == ChessTag.PAO then 		tagStr = "C"
	elseif _chessTag == ChessTag.BING then 		tagStr = "P"
	end

	local colorStr = "--"
	if chessColor == ChessColor.RED then
		colorStr = "R"
	elseif chessColor == ChessColor.BLACK then
		colorStr = "B"
	end

	return "ChessStyle_5_"..colorStr..tagStr..".png"
end

function MainScene:getPostionByPosId(posId)
	local offSet = {x=40,y = 75}
	local startPos = {x=offSet.x*self.boardBg:getScale(),y=display.cy-(self.boardBg:getContentSize().height/2-offSet.y)*self.boardBg:getScale()}
	local girdSize = {width = 70*self.boardBg:getScale(),height = 69*self.boardBg:getScale()}
	local coord = Manager.getCoordinateByPosId(posId)
	local retPos = {x = startPos.x + (coord.x-1)*girdSize.width,y = startPos.y + (coord.y-1)*girdSize.height}
	return retPos
end

function MainScene:getPosIdByPosition(postion)
	local min = 99999
	local retPosId
	for i=1,90 do
		local tmpPos = self:getPostionByPosId(i)
		local distance = math.sqrt((tmpPos.x-postion.x)*(tmpPos.x-postion.x) + (tmpPos.y-postion.y)*(tmpPos.y-postion.y))
		if distance<min then
			min = distance
			retPosId = i
		end
	end
	return retPosId
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
