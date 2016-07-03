local os = os
local math = math
local print 		= print
local dump 			= dump
local writeTabToLog = writeTabToLog
local coroutine 	= coroutine
local BoardState = require("app.utils.BoardState")

local M = class("Robot")
package.loaded[...] = M
setfenv(1,M)

local MAX_VALUE = 9999
local MIN_VALUE = -9999

local MAX_TIME 	= 0.8
local MAX_DEPTH = 2

local maxTable = {}  	
local minTable = {}

local function setMaxFastTable(key,value)
	if maxTable[key]==nil or (maxTable[key].maxDepth-maxTable[key].depth<value.maxDepth-value.depth) then 	--如果是已经记录过，但是之前的更浅，则更新
		maxTable[key] = value
	end
end

local function setMinFastTable(key,value)
	if minTable[key]==nil or minTable[key].maxDepth-minTable[key].depth<value.maxDepth-value.depth then 	--如果是已经记录过，但是之前的更浅，则更新
		minTable[key] = value
	end
end

local function loadMaxFastByKey(key,maxDepth,depth)
	if maxTable[key]~=nil then
		local tab = maxTable[key]
		--第二个返回值：相同局面下，现有的记录是思考较深的结果（maxDepth-depth），则true
		return tab ,tab.maxDepth-tab.depth>=maxDepth-depth
	end
end

local function loadMinFastByKey(key,maxDepth,depth)
	if minTable[key]~=nil then
		local tab = minTable[key]
		--第二个返回值：相同局面下，现有的记录是思考较深的结果（maxDepth-depth），则true
		return tab ,tab.maxDepth-tab.depth>=maxDepth-depth
	end
end

function ctor(self)
	self:setRobotLevel(3)
end

function setRobotLevel(self,level)
	MAX_DEPTH 	= 10
	if level==1 then
		MAX_TIME = 2
	elseif level==2 then
		MAX_TIME = 4
	elseif level==3 then
		MAX_TIME = 9
	end
	print("MAX_TIME",MAX_TIME)
end

function getNextMoveData(self,_curState)
	writeTabToLog({},"","1kkk.lua",2)
	diedai_count = 0
	self.startTime = os.clock()
	_curState.depth = 0
	local depth = MAX_DEPTH
	local value,bestNextMove
	local oldBest = nil
	for i=2,depth do
		MAX_DEPTH = i
		if _curState.isMyTurn then
			value ,bestNextMove= self:maxValue(_curState,MIN_VALUE,MAX_VALUE)
		else
			value ,bestNextMove= self:minValue(_curState,MIN_VALUE,MAX_VALUE)
		end
		writeTabToLog({index=i,usedtime=(self.curTime or self.startTime)-self.startTime,value=value ,bestNextMove=bestNextMove},"迭代次数，时间","1kkk.lua")
		diedai_count = i
		if (self.curTime or self.startTime)-self.startTime>MAX_TIME and oldBest~=nil then
			bestNextMove = oldBest
			break
		end
		oldBest = bestNextMove
	end
	MAX_DEPTH = depth

	return bestNextMove
end

function maxValue(self,state,alpha,beta)
	coroutine.yield()
	local _tab,isBetter = loadMaxFastByKey(state:getKey(),MAX_DEPTH,state.depth)
	if isBetter then 	--置换表里已经存了一个思考更深入的走法
		return _tab.value,_tab.bestNextMove
	end
	if state.depth==MAX_DEPTH then
		return state:getEvaluation()
	end
	self.curTime = os.clock()
	if self.curTime - self.startTime>MAX_TIME then 	--要超时了，停止搜索
		return state:getEvaluation()
	end
	state.value = MIN_VALUE-1
	local _minValue = MIN_VALUE 	--用于标记一群极小点中最大的
	local nextStates = state:getNextStateList()
	if #nextStates==0 then
		return state:getEvaluation()
	end
	if _tab and _tab.stateKey then 	--有还不错的走法，优先走
		local index = 1
		for i=1,#nextStates do
			if nextStates[i]:getKey()==_tab.stateKey then
				index = i
				break
			end
		end
		if index~=1 then
			local tmp = nextStates[index]
			nextStates[index] = nextStates[1]
			nextStates[1] = tmp
		end
	end
	local bestNextState = nil
	for i=1,#nextStates do  	--遍历当前情况所有走法
		local v = nextStates[i]
		v.depth = state.depth + 1 	--搜索深度+1

		local tmpValue = self:minValue(v,alpha,beta) 	--下一层是找极小点
		-- writeTabToLog({tmpValue=tmpValue or nil,depth = v.depth or nil,moveData = v:getMoveData()},"极小","1kkk.lua")
		if _minValue < tmpValue then
			_minValue = tmpValue 	--要在下一层所有极小点中，找出一个最大的
		end
		if _minValue>state.value then 	--如果最大的比当前值大，则改写当前值
			bestNextState = v
			state.value = _minValue
		end

		if state.value>=beta then  --当前值大于beta，剪枝
			setMaxFastTable(state:getKey(),{value = state.value,depth = state.depth,maxDepth = MAX_DEPTH,bestNextMove = v:getMoveData()})
			return state.value,v:getMoveData()
		end

		--如果当前值比alpha值大，更新alpha值
		alpha = alpha>state.value and alpha or state.value
	end
	setMaxFastTable(state:getKey(),{value = state.value,depth = state.depth,maxDepth = MAX_DEPTH,bestNextMove = bestNextState:getMoveData(),stateKey = bestNextState:getKey()})
	return state.value,bestNextState:getMoveData()
end

function minValue(self,state,alpha,beta)
	local _tab,isBetter = loadMinFastByKey(state:getKey(),MAX_DEPTH,state.depth)
	if isBetter then 	--置换表里已经存了一个思考更深入的走法
		return _tab.value,_tab.bestNextMove
	end
	if state.depth==MAX_DEPTH then
		return state:getEvaluation()
	end
	self.curTime = os.clock()
	if self.curTime - self.startTime>MAX_TIME then 	--要超时了，停止搜索
		return state:getEvaluation()
	end
	state.value = MAX_VALUE+1

	local _maxValue = MAX_VALUE 	--用于标记一群极大点中最小的
	local nextStates = state:getNextStateList()
	if #nextStates==0 then
		return state:getEvaluation()
	end
	if _tab and _tab.stateKey then
		local index = 1
		for i=1,#nextStates do
			if nextStates[i]:getKey()== _tab.stateKey then
				index = i
				break
			end
		end
		if index~=1 then
			local tmp = nextStates[index]
			nextStates[index] = nextStates[1]
			nextStates[1] = tmp
		end
	end
	local bestNextState = nil
	for i=1,#nextStates do  	--遍历当前情况所有走法
		local v = nextStates[i]
		v.depth = state.depth + 1 	--搜索深度+1

		local tmpValue = self:maxValue(v,alpha,beta) 	--下一层是找极大点
		-- writeTabToLog({tmpValue=tmpValue or nil,depth = v.depth or nil,moveData = v:getMoveData()},"极大","1kkk.lua")
		if _maxValue > tmpValue then
			_maxValue = tmpValue 	--要在下一层所有极大点中，找出一个最小的
		end
		if _maxValue<state.value then 	--如果最小的比当前值小，则改写当前值
			bestNextState = v
			state.value = _maxValue
		end

		if state.value<=alpha then
			setMinFastTable(state:getKey(),{value = state.value,depth = state.depth,maxDepth = MAX_DEPTH,bestNextMove = v:getMoveData(),stateKey = v:getKey()})
			return state.value,v:getMoveData()
		end

		--如果当前值比beta值小，更新beta值
		beta = beta<state.value and beta or state.value
	end
	setMinFastTable(state:getKey(),{value = state.value,depth = state.depth,maxDepth = MAX_DEPTH,bestNextMove = bestNextState:getMoveData(),stateKey = bestNextState:getKey()})
	return state.value,bestNextState:getMoveData()
end