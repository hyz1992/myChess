local math 			= math
local Chess = Chess
local ChessColor 	= ChessColor
local ChessTag 		= ChessTag
local print 		= print
local dump 			= dump
local pairs			= pairs
local table 		= table
local Manager = require("app.utils.Manager")
local setProxy = setProxy
local Chess = Chess
local M = class("BoardState")
package.loaded[...] = M
setfenv(1,M)

local chessId_offset = 128

local MAX_VALUE = 9999
local MIN_VALUE = -9999

function ctor(self,myChesses,otherChesses,isMyTurn)
	self.mChess = {}
	self.oChess = {}
	for i=1,16 do
		self.mChess[i] = setProxy(Chess.new())
		self.oChess[i] = setProxy(Chess.new())

		self.mChess[i]:clone(myChesses[i])
		self.oChess[i]:clone(otherChesses[i])
	end

	self.isMyTurn = isMyTurn
	self.manger = Manager.new(self.mChess,self.oChess)

	self.moveData = nil 	--记录从上一步到这一步的走法
	self.depth = 0		--当前状态的搜索深度
	self.value = 0 		--当前状态的权值
end

function getMoveData(self)
	return self.moveData
end

function getChessByChessId(self,chessId)
	if math.floor(chessId/chessId_offset)==1 then 		--我的棋子
		return self.mChess[chessId%chessId_offset]
	elseif math.floor(chessId/chessId_offset)==2 then 	--对方的棋子
		return self.oChess[chessId%chessId_offset]
	else
		error("error chessId:",chessId)
	end
end

function getNextStateList(self)
	-- writeTabToLog({},"","1ggg.lua",2)
	local ret = {}
	local chesses
	if self.isMyTurn then
		chesses = self.mChess
	else
		chesses = self.oChess
	end

	for i=1,16 do
		local chess = chesses[i]
		if 0==chess:getIsDead() then
			local tmpTab = self:nextState(chess)  --找到每个棋子下一步有可能的状态
			for k,v in pairs(tmpTab) do
				ret[#ret+1] = v
			end
		end
	end

	return ret
end

function nextState(self,chess)
	local ret = {}
	self.manger:setChess(self.mChess,self.oChess)
	local poses = self.manger:getPosCanTouch(chess)
	local curPosId = chess:getPosId()
	if #poses==0 then
		return ret
	end

	for i=1,#poses do
		local newPosId = poses[i].pos
		local eatId = poses[i].eat
		local eatChess = nil
		if eatId then
			eatChess = self:getChessByChessId(eatId)
			eatChess:setIsDead(1)
		end
		chess:setPosId(newPosId)
		local isMyTurn = not self.isMyTurn
		local newState = M.new(self.mChess,self.oChess,isMyTurn)
		chess:setPosId(curPosId)
		if eatChess then
			eatChess:setIsDead(0)
		end
		newState.moveData = {chessId = chess:getChessId(),dstPos = newPosId,eatChessId = eatChess and eatChess:getChessId()}
		ret[#ret+1] = newState
	end

	return ret
end
--[[
	棋子的价值
	棋子位置的价值
	棋子的灵活性
	棋子的威胁与保护
]]
function getEvaluation(self)
	--if 1 then return math.random(1,10) end	
	local value = 0
	local chessPower 	= {6,4,3,2,100,5,1}
	local posPower 		= {1,2,3,4,5,6,7,8,9,10}

	local chess,posId,coord,poses
	for i=1,16 do
		chess = self.mChess[i]
		posId = chess:getPosId()
		coord = self.manger:getCoordinateByPosId(posId)
		poses = self.manger:getPosCanTouch(chess)
		if 0==chess:getIsDead() then
			value = value + chessPower[chess:getChessTag()]*10
			value = value + posPower[coord.y]*2
			value = value + #poses*2
			for k,v in pairs(poses) do
				if v.eat then
					local eatChess = self:getChessByChessId(v.eat)
					value = value + chessPower[eatChess:getChessTag()]
				end
			end
		end

		chess = self.oChess[i]
		posId = chess:getPosId()
		coord = self.manger:getCoordinateByPosId(posId)
		poses = self.manger:getPosCanTouch(chess)
		if 0==chess:getIsDead() then
			value = value - chessPower[chess:getChessTag()]*10
			value = value - posPower[11-coord.y]*2
			value = value - #poses*2
			for k,v in pairs(poses) do
				if v.eat then
					local eatChess = self:getChessByChessId(v.eat)
					value = value + chessPower[eatChess:getChessTag()]
				end
			end
		end
	end


	return value
end

function getKey(self)
	local key = ""
	local tab = {}
	for i=1,16 do
		if 0==self.mChess[i]:getIsDead() then
			tab[#tab+1] = self.mChess[i]:getChessId()..","..self.mChess[i]:getPosId()..";"
		end
	end
	for i=1,16 do
		if 0==self.oChess[i]:getIsDead() then
			tab[#tab+1] = self.oChess[i]:getChessId()..","..self.oChess[i]:getPosId()..";"
		end
	end
	local key = table.concat(tab)
	return key
end

function equal(self,state)
	return self:getKey()==state:getKey()
end