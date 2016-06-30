require("app.data.chess")

local math 			= math
local ChessColor 	= ChessColor
local ChessTag 		= ChessTag
local print 		= print
local dump 			= dump

local M = class("Manager")
package.loaded[...] = M
setfenv(1,M)

function ctor(self,myChesses,otherChesses)
	self:setChess(myChesses,otherChesses)
end

function setChess(self,myChesses,otherChesses)
	self.mChess = myChesses
	self.oChess = otherChesses
end

--根据位置posId得到矩阵坐标，返回的矩阵坐标以左下角为原点
function getCoordinateByPosId(self,posId)
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

function getPosIdByCoordinate(self,coord)
	local posId = (coord.y-1)*9 + coord.x
	return posId
end

--返回值，1：目标位置有红方的棋，2：目标位置有白方的棋，0：目标位置空白
function checkHasChess(self,targetPos)
	for i=1,16 do
		if self.mChess[i]:getIsDead()==0 and self.mChess[i]:getPosId()==targetPos then
			return ChessColor.RED,self.mChess[i]
		end
		if self.oChess[i]:getIsDead()==0 and self.oChess[i]:getPosId()==targetPos then
			return ChessColor.BLACK,self.oChess[i]
		end
	end
	return 0
end

function ifCanGo(self,chess,targetPosId)
	local poses = self:getPosCanTouch(chess)
	for i=1,#poses do
		if poses[i].pos==targetPosId then
			return true
		end
	end
	return false
end

function getPosCanTouch(self,chess)
	-- chess:print()
	local retChesses = {}
	local isMyChess = chess:getIsMyChess()
	local chessTag = chess:getChessTag()
	local curPosId = chess:getPosId()
	local curCoord = self:getCoordinateByPosId(curPosId)
	local offset = {}
	-- print("curPosId:",curPosId)
	-- print(chessTag==ChessTag.XIANG,chessTag,ChessTag.XIANG)
	if chessTag==ChessTag.JU then
		offset = {
			{x = 0, y =1},{x = 1, y =0},{x = 0, y =-1},{x = -1, y =0},
		}
		for i=1 ,#offset do
			local dis = 1
			local _offset = offset[i]
			local tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
			while tmpCoord.x>=1 and tmpCoord.x<=9 and tmpCoord.y>=1 and tmpCoord.y<=10  do 	--边界以内才有效
				print(tmpCoord.x,tmpCoord.y)
				local tmpPos = self:getPosIdByCoordinate(tmpCoord)
				local color,eatchess = self:checkHasChess(tmpPos)
				if color==ChessColor.NONE then 	--目标位置没有棋
					retChesses[#retChesses+1] = {pos =tmpPos} --返回的是可以到达的位置
					dis = dis + 1
					tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
				elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then 	--有对方的棋
					retChesses[#retChesses+1] = {pos =tmpPos,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置,以及可以吃的棋子chessId
					dis = dis + 1
					tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
					break
				else
					break
				end
			end
		end
	elseif chessTag==ChessTag.MA then
		offset = {
			{x = 1, y =2},{x = 2, y =1},{x = 2, y =-1},{x = 1, y =-2},{x = -1, y =-2},{x = -2, y =-1},{x = -2, y =1},{x = -1, y =2},
		}
		for i=1 ,#offset do
			local _offset = offset[i]
			local leg = {x =_offset.x/2,y =_offset.y/2} 	--马脚
			if math.abs(leg.x)<1 then leg.x = 0 end
			if math.abs(leg.y)<1 then leg.y = 0 end
			local tmpCoord = {x = curCoord.x + _offset.x,y = curCoord.y+_offset.y}
			local legCoord = {x = curCoord.x + leg.x,y = curCoord.y+leg.y}
			if tmpCoord.x>=1 and tmpCoord.x<=9 and tmpCoord.y>=1 and tmpCoord.y<=10  then 	--边界以内才有效
				local legPos = self:getPosIdByCoordinate(legCoord)
				local tmpPos = self:getPosIdByCoordinate(tmpCoord)
				local color,eatchess = self:checkHasChess(legPos)
				if color==ChessColor.NONE then 		--马脚有棋就不能走
					color,eatchess = self:checkHasChess(tmpPos)
					if color==ChessColor.NONE then
						retChesses[#retChesses+1] = {pos =tmpPos}
					elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then
						retChesses[#retChesses+1] = {pos =tmpPos,eat =eatchess and eatchess:getChessId()}
					end
				end
			end
		end
	elseif chessTag==ChessTag.PAO then
		offset = {
			{x = 0, y =1},{x = 1, y =0},{x = 0, y =-1},{x = -1, y =0},
		}
		for i=1 ,#offset do
			local dis = 1
			local _offset = offset[i]
			local tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
			while tmpCoord.x>=1 and tmpCoord.x<=9 and tmpCoord.y>=1 and tmpCoord.y<=10  do 	--边界以内才有效
				local tmpPos = self:getPosIdByCoordinate(tmpCoord)
				local color,eatchess = self:checkHasChess(tmpPos)
				if color==ChessColor.NONE then 	--目标位置没有棋
					retChesses[#retChesses+1] = {pos =tmpPos} --返回的是可以到达的位置
					dis = dis + 1
					tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
				else
					dis = dis + 1
					tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
					while tmpCoord.x>=1 and tmpCoord.x<=9 and tmpCoord.y>=1 and tmpCoord.y<=10  do 	--边界以内才有效
						local tmpPos = self:getPosIdByCoordinate(tmpCoord)
						local color,eatchess = self:checkHasChess(tmpPos)
						if color==ChessColor.NONE then
							dis = dis + 1
							tmpCoord = {x = curCoord.x + _offset.x*dis,y = curCoord.y+_offset.y*dis}
						elseif color==chess:getColor() then
							break
						elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then
							retChesses[#retChesses+1] = {pos =tmpPos,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置
							break
						end
					end
					break
				end
			end
		end
	elseif chessTag==ChessTag.BING then
		if isMyChess then
			if curCoord.y<=5 then
				offset = {
					{x =0,y =1},
				}
			else
				offset = {
					{x =0,y=1},{x =-1,y=0},{x =1,y=0}
				}
			end
		else
			if curCoord.y>=6 then
				offset = {
					{x =0,y =-1},
				}
			else
				offset = {
					{x =0,y=-1},{x =-1,y=0},{x =1,y=0}
				}
			end
		end
		-- dump(offset)
		for i=1,#offset do
			local _offset = offset[i]
			local tmpCoord = {x = curCoord.x + _offset.x,y = curCoord.y+_offset.y}
			if tmpCoord.x>=1 and tmpCoord.x<=9 and tmpCoord.y>=1 and tmpCoord.y<=10  then 	--边界以内才有效
				local tmpPos = self:getPosIdByCoordinate(tmpCoord)
				local color,eatchess = self:checkHasChess(tmpPos)
				if color==ChessColor.NONE then 	--目标位置没有棋
					retChesses[#retChesses+1] = {pos =tmpPos} --返回的是可以到达的位置
				elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then	--有对方的棋
					retChesses[#retChesses+1] = {pos =tmpPos,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置,以及可以吃的棋子chessId
				end
			end
		end
	elseif chessTag==ChessTag.XIANG then
		if isMyChess then
			offset = {
				{src =3,leg =11,dst =19},{src =3,leg =13,dst =23},
				{src =39,leg =29,dst =19},{src =39,leg =31,dst =23},
				{src =7,leg =17,dst =27},{src =7,leg =15,dst =23},
				{src =43,leg =35,dst =27},{src =43,leg =33,dst =23},

				{src =23,leg =13,dst =3},{src =23,leg =15,dst =7},
				{src =23,leg =31,dst =39},{src =23,leg =33,dst =43},

				{src =19,leg =11,dst =3},{src =19,leg =29,dst =39},
				{src =27,leg =17,dst =7},{src =27,leg =35,dst =43},
			}
		else
			offset = {
				{src =84,leg =74,dst =64},{src =84,leg =76,dst =68},
				{src =48,leg =56,dst =64},{src =48,leg =58,dst =68},
				{src =88,leg =78,dst =68},{src =88,leg =80,dst =72},
				{src =52,leg =60,dst =68},{src =52,leg =62,dst =72},

				{src =68,leg =76,dst =84},{src =68,leg =78,dst =88},
				{src =68,leg =58,dst =48},{src =68,leg =60,dst =52},

				{src =64,leg =74,dst =84},{src =64,leg =56,dst =48},
				{src =72,leg =80,dst =88},{src =72,leg =62,dst =52},
				
			}
		end
		for i=1,#offset do
			local _offset = offset[i]
			if curPosId==_offset.src then
				local color,eatchess = self:checkHasChess(_offset.leg)
				if color==ChessColor.NONE then 	--象脚没有棋才行
					color,eatchess = self:checkHasChess(_offset.dst)
					if color==ChessColor.NONE then 	--目标位置没有棋
						retChesses[#retChesses+1] = {pos =_offset.dst} --返回的是可以到达的位置
					elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then	--有对方的棋
						retChesses[#retChesses+1] = {pos =_offset.dst,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置,以及可以吃的棋子chessId
					end
				end
			end
		end
	elseif chessTag==ChessTag.SHI then
		if isMyChess then
			offset = {
				{src =4,dst =14},{src =6,dst =14},{src =22,dst =14},{src =24,dst =14},
				{src =14,dst =4},{src =14,dst =6},{src =14,dst =22},{src =14,dst =24},
			}
		else
			offset = {
				{src =85,dst =77},{src =67,dst =77},{src =87,dst =77},{src =69,dst =77},
				{src =77,dst =85},{src =77,dst =67},{src =77,dst =87},{src =77,dst =69},				
			}
		end
		for i=1,#offset do
			local _offset = offset[i]
			if curPosId==_offset.src then
				local color,eatchess = self:checkHasChess(_offset.dst)
				if color==ChessColor.NONE then 	--目标位置没有棋
					retChesses[#retChesses+1] = {pos =_offset.dst} --返回的是可以到达的位置
				elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then	--有对方的棋
					retChesses[#retChesses+1] = {pos =_offset.dst,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置,以及可以吃的棋子chessId
				end
			end
		end
	elseif chessTag==ChessTag.JIANG then
		if isMyChess then
			offset = {
				{src =4,dst =13},{src =4,dst =5},{src =5,dst =4},{src =5,dst =6},
				{src =6,dst =5},{src =6,dst =15},{src =15,dst =6},{src =15,dst =24},
				{src =24,dst =15},{src =24,dst =23},{src =23,dst =22},{src =23,dst =24},
				{src =22,dst =13},{src =22,dst =23},{src =13,dst =22},{src =13,dst =4},
				{src =5,dst =14},{src =15,dst =14},{src =13,dst =14},{src =23,dst =14},
				{src =14,dst =5},{src =14,dst =15},{src =14,dst =13},{src =14,dst =23},
			}
		else
			offset = {
				{src =85,dst =76},{src =85,dst =86},{src =86,dst =85},{src =86,dst =87},
				{src =87,dst =86},{src =87,dst =78},{src =78,dst =87},{src =78,dst =69},
				{src =69,dst =68},{src =69,dst =78},{src =68,dst =67},{src =68,dst =69},
				{src =67,dst =76},{src =67,dst =68},{src =76,dst =85},{src =76,dst =67},
				{src =76,dst =77},{src =86,dst =77},{src =68,dst =77},{src =78,dst =77},
				{src =77,dst =76},{src =77,dst =86},{src =77,dst =68},{src =77,dst =78},
			}
		end
		for i=1,#offset do
			local _offset = offset[i]
			if curPosId==_offset.src then
				local color,eatchess = self:checkHasChess(_offset.dst)
				if color==ChessColor.NONE then 	--目标位置没有棋
					retChesses[#retChesses+1] = {pos =_offset.dst} --返回的是可以到达的位置
				elseif color==ChessColor.RED+ChessColor.BLACK - chess:getColor() then	--有对方的棋
					retChesses[#retChesses+1] = {pos =_offset.dst,eat =eatchess and eatchess:getChessId()} --返回的是可以到达的位置,以及可以吃的棋子chessId
				end
			end
		end
	end
	return retChesses
end
