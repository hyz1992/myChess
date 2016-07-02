local math 			= math
local Chess = Chess
local ChessColor 	= ChessColor
local ChessTag 		= ChessTag
local print 		= print
local dump 			= dump
local pairs			= pairs
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