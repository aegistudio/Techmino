local gc=love.graphics
local rnd=math.random
return{
	color=color.orange,
	env={
		drop=60,lock=60,
		target=100,dropPiece=player.reach_winCheck,
		bg="strap",bgm="race",
	},
	load=function()
		newPlayer(1,340,15)
	end,
	mesDisp=function(P)
		local dx,dy=P.fieldOff.x,P.fieldOff.y
		setFont(55)
		local r=100-P.stat.row
		if r<0 then r=0 end
		mStr(r,-81,265)
		if r<21 and r>0 then
			gc.setLineWidth(4)
			gc.setColor(1,r>10 and 0 or rnd(),.5)
			gc.line(dx,600-30*r+dy,300+dx,600-30*r+dy)
		end
	end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
	scoreDisp=function(D)return toTime(D[1]).."   "..D[2].." Pieces"end,
	comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		if P.stat.row<100 then return end
		local T=P.stat.time
		return
		T<=62 and 5 or
		T<=90 and 4 or
		T<=130 and 3 or
		T<=200 and 2 or
		T<=360 and 1 or
		0
	end,
}