local os = os
local math = math
local print 		= print
local dump 			= dump
local BoardState = require("app.utils.BoardState")

local M = class("Robot")
package.loaded[...] = M
setfenv(1,M)

local MAX_VALUE = 9999
local MIN_VALUE = -9999

local MAX_TIME 	= 0.8
local MAX_DEPTH = 2

function ctor()
	MAX_DEPTH = 2
end

function getNextMoveData(_curState)
	local list = _curState:getNextStateList()
	return list[math.random(1,#list)]:getMoveData()
end