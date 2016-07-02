local Manager = require("app.utils.Manager")
local BoardState = require("app.utils.BoardState")
local Robot = require("app.utils.Robot").new()
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local FightType = {
	online = 1,		--网络版
	offline_1 = 2, 	--与AI下
	offline_2 = 3,  --与自己下
}

local chessId_offset = 128 	--我的棋chessId起始偏移量

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

    self.manger = Manager.new(self.mChess,self.oChess)
    --self.manger:setChess(self.mChess,self.oChess)

    self.fightType = FightType.offline_1

    self:initChess()
    
    for i=1,90 do
    	local pos = self:getPostionByPosId(i)
    	display.newTTFLabel({text=i.."",color = cc.c3b(0,255,255)})
    		:addTo(self)
    		:pos(pos.x,pos.y)
    end
    self.tipNode = display.newNode()
    	:addTo(self,1)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
    	if event.name=="began" then
    		local targetPosId = self:getPosIdByPosition({x = event.x,y = event.y})
    		self:sendMoveChess(targetPosId)
    	end
	end)

    self.isMyTurn = false
	self:sendNextMove()
end

function MainScene:initChess()
	self.mChess = {}
	self.oChess = {}
	for i=1,16 do
		self.mChess[i] = setProxy(Chess.new())
		self.oChess[i] = setProxy(Chess.new())
	end
	local posArr = {1,2,3,4,5,6,7,8,9,20,26,28,30,32,34,36}
	local tagArr = {ChessTag.JU,ChessTag.MA,ChessTag.XIANG,ChessTag.SHI,ChessTag.JIANG,ChessTag.SHI,ChessTag.XIANG,ChessTag.MA,ChessTag.JU,
						ChessTag.PAO,ChessTag.PAO,ChessTag.BING,ChessTag.BING,ChessTag.BING,ChessTag.BING,ChessTag.BING}
	for i=1,16 do
		local mychess = self.mChess[i]
		local myChessItem = display.newSprite("#ChessStyle_5_BA.png")
				:addTo(self)
		UIEx.bind(myChessItem,mychess,"id",function (value)
			local posId = posArr[i]
			mychess:setPosId(posId)
			mychess:setNode(myChessItem)
			mychess:setChessId(chessId_offset+i)
			mychess:setColor(ChessColor.RED)
			mychess:setChessTag(tagArr[i])
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
		UIEx.bind(myChessItem,mychess,"isDead",function (value)
			myChessItem:setVisible(value==0)
		end)
		myChessItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)		
			if event.name=="began" then
				self.selectChess = mychess
				myChessItem:scale(0.97)
				self.manger:setChess(self.mChess,self.oChess)
				local poses = self.manger:getPosCanTouch(mychess)
				self:showSelectedTip(mychess:getPosId())
				self:showChessTips(poses)
				myChessItem:setLocalZOrder(10)
			elseif event.name == "moved" then
				myChessItem:pos(event.x,event.y)
	        elseif event.name == "ended" then
	        	myChessItem:scale(1)
	        	
	        	local targetPosId = self:getPosIdByPosition({x = event.x,y = event.y})
	        	if self.manger:ifCanGo(mychess,targetPosId) then
	        		local targetPostion = self:getPostionByPosId(targetPosId)
	        		myChessItem:pos(targetPostion.x,targetPostion.y)
	        		self:sendMoveChess(targetPosId)
	        	else
	        		if targetPosId~=mychess:getPosId() then
	        			self.selectChess = nil
	        		end
	        		local pos = self:getPostionByPosId(mychess:getPosId())
	        		myChessItem:pos(pos.x,pos.y)
	        		return
	        	end
	        	
			end
			return true
		end)
		mychess:setId(i)
	end

	posArr = {82,83,84,85,86,87,88,89,90,65,71,55,57,59,61,63}
	for i=1,16 do
		local otchess = self.oChess[i]
		local otChessItem = display.newSprite("#ChessStyle_5_BA.png")
				:addTo(self)
		UIEx.bind(otChessItem,otchess,"id",function (value)
			local posId = posArr[i]
			otchess:setPosId(posId)
			otchess:setNode(otChessItem)
			otchess:setChessId(chessId_offset*2+i)
			otchess:setColor(ChessColor.BLACK)
			otchess:setChessTag(tagArr[i])
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
		UIEx.bind(otChessItem,otchess,"isDead",function (value)
			otChessItem:setVisible(value==0)
		end)
		otChessItem:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)			
			if event.name=="began" then
				self.selectChess = otchess
				otChessItem:scale(0.97)
				local poses = self.manger:getPosCanTouch(otchess)
				self:showSelectedTip(otchess:getPosId())
				self:showChessTips(poses)
				otChessItem:setLocalZOrder(10)
				
			elseif event.name == "moved" then
				otChessItem:pos(event.x,event.y)
	        elseif event.name == "ended" then
	        	otChessItem:scale(1)
	        	local targetPosId = self:getPosIdByPosition({x = event.x,y = event.y})
	        	if self.manger:ifCanGo(otchess,targetPosId) then
	        		local targetPostion = self:getPostionByPosId(targetPosId)
	        		otChessItem:pos(targetPostion.x,targetPostion.y)
	        		self:sendMoveChess(targetPosId)
	        	else
	        		if targetPosId~=otchess:getPosId() then
	        			self.selectChess = nil
	        		end
	        		local pos = self:getPostionByPosId(otchess:getPosId())
	        		otChessItem:pos(pos.x,pos.y)
	        		return
	        	end
			end
			return true
		end)

		otchess:setId(i)
	end
end

function MainScene:getImgPath(_chessTag,chessColor)
	local tagStr = "--"
	if _chessTag == ChessTag.JU then 			tagStr = "R"
	elseif _chessTag == ChessTag.MA then 		tagStr = "N"
	elseif _chessTag == ChessTag.XIANG then 	tagStr = "B"
	elseif _chessTag == ChessTag.SHI then 		tagStr = "A"
	elseif _chessTag == ChessTag.JIANG then 	tagStr = "K"
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
	local coord = self.manger:getCoordinateByPosId(posId)
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

function MainScene:showChessTips(poses)
	self.tipNode:removeAllChildren()
	for i=1,#poses do
		local pos = self:getPostionByPosId(poses[i].pos)
		display.newSprite("tip.png")
			:addTo(self.tipNode)
			:pos(pos.x,pos.y)
	end
end

function MainScene:hideChessTips()
	self.tipNode:removeAllChildren()
end

function MainScene:showMovedTip(target)
	self:hideMovedTip()
	if self.movedTip == nil then
		self.movedTip = display.newSprite("chess_moved.png")
			:addTo(self,1)
	end
	local pos = self:getPostionByPosId(target)
	self.movedTip:pos(pos.x,pos.y)
	self.movedTip:setVisible(true)
end

function MainScene:hideMovedTip()
	if self.movedTip then
		self.movedTip:setVisible(false)
	end
end

function MainScene:showSelectedTip(target)
	self:hideSelectedTip()
	if self.selectedTip == nil then
		self.selectedTip = display.newSprite("selectBg.png")
			:addTo(self,2)
	end
	local pos = self:getPostionByPosId(target)
	self.selectedTip:pos(pos.x,pos.y)
	self.selectedTip:setVisible(true)
end

function MainScene:hideSelectedTip()
	if self.selectedTip then
		self.selectedTip:setVisible(false)
	end
end

--发送走棋
function MainScene:sendMoveChess(targetPosId)
	if self.selectChess==nil then
		return
	end
	local canGo,eat = self.manger:ifCanGo(self.selectChess,targetPosId)
	if canGo then
		local data = {chessId = self.selectChess:getChessId(),dstPos = targetPosId,eatChessId = eat}
		self:onChessMove(data)
		
	else
		self.selectChess = nil
	end
end

function MainScene:getChessByChessId(chessId)
	if math.floor(chessId/chessId_offset)==1 then 		--我的棋子
		return self.mChess[chessId%chessId_offset]
	elseif math.floor(chessId/chessId_offset)==2 then 	--对方的棋子
		return self.oChess[chessId%chessId_offset]
	else
		error("error chessId:",chessId)
	end
end

--走棋,data{dstPos,chessId,eatChessId}
function MainScene:onChessMove( data )
	self.selectChess = nil
	self:hideSelectedTip()
	self:hideChessTips()
	local chess = self:getChessByChessId(data.chessId)
	chess:setPosId(data.dstPos)
	local pos = self:getPostionByPosId(data.dstPos)
	local node = chess:getNode()
	local delay = 0.2
	if pos.x==node:getPositionX() and pos.y==node:getPositionY() then
		delay=0
	end
	local seq = transition.sequence({
        cc.MoveTo:create(0.2,cc.p(pos.x,pos.y)),
        cc.CallFunc:create(function (  )
        	self:showMovedTip(data.dstPos)
        	node:setLocalZOrder(0)
        	print("data.eatChessId:",data.eatChessId)
        	if data.eatChessId then
        		self:getChessByChessId(data.eatChessId):setIsDead(true)
        	end
        	self:sendNextMove()
        end),
    })
	node:runAction(seq)
end

--改变棋手
function MainScene:sendNextMove()
	self.isMyTurn = not self.isMyTurn
	self:onNextMove()
end
--轮到谁下
function MainScene:onNextMove(data)
	
	if self.isMyTurn then
		for i=1,16 do
			self.mChess[i]:setMoveable(true)
			self.oChess[i]:setMoveable(false)
		end
	else
		for i=1,16 do
			self.mChess[i]:setMoveable(false)
			self.oChess[i]:setMoveable(true)
		end
	end

	if self.fightType==FightType.offline_1 and not self.isMyTurn then 	--在与电脑下的状态下，轮到电脑下
		local _state = BoardState.new(self.mChess,self.oChess,self.isMyTurn)
		local movedata = Robot.getNextMoveData(_state)
		-- dump(movedata)
		self:onChessMove(movedata)
	else
	end

end
--游戏开始
function MainScene:sendGameStart()
	-- body
end

function MainScene:onGameStart(data)
	-- body
end
--游戏结束
function MainScene:sendGameEnd()
	-- body
end

function MainScene:onGameEnd(data)
	-- body
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
