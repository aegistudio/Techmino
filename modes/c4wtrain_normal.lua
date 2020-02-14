local rnd=math.random
local function check_c4w(P)
	for i=1,#P.cleared do
		P.field[#P.field+1]=getNewRow(10)
		P.visTime[#P.visTime+1]=getNewRow(20)
		for i=4,7 do P.field[#P.field][i]=0 end
	end
	if #P.cleared>0 then
		if P.combo>P.modeData.point then
			P.modeData.point=P.combo
		end
		if P.stat.row>=100 then
			Event.win(P,"finish")
		end
	end
end

return{
	name={
		"C4W练习",
		"中四宽练习",
		"C4W Train",
	},
	level={
		"普通",
		"普通",
		"NORMAL",
	},
	info={
		"无 限 连 击",
		"无 限 连 击",
		"Infinite combo",
	},
	color=color.green,
	env={
		drop=30,lock=60,oncehold=false,
		dropPiece=check_c4w,
		freshLimit=15,ospin=false,
		bg="rgb",bgm="newera",
	},
	load=function()
		newPlayer(1,340,15)
		local P=players[1]
		local F=P.field
		for i=1,24 do
			F[i]=getNewRow(10)
			P.visTime[i]=getNewRow(20)
			for x=4,7 do F[i][x]=0 end
		end
		local r=rnd(6)
		if r==1 then	 F[1][5],F[1][4],F[2][4]=10,10,10
		elseif r==2 then F[1][6],F[1][7],F[2][7]=10,10,10
		elseif r==3 then F[1][4],F[2][4],F[2][5]=10,10,10
		elseif r==4 then F[1][7],F[2][7],F[2][6]=10,10,10
		elseif r==5 then F[1][4],F[1][5],F[1][6]=10,10,10
		elseif r==6 then F[1][7],F[1][6],F[1][5]=10,10,10
		end
	end,
	mesDisp=function(P,dx,dy)
		setFont(45)
		mStr(P.combo,-82,310)
		mStr(P.modeData.point,-82,400)
		mDraw(drawableText.combo,-82,358)
		mDraw(drawableText.mxcmb,-82,450)
	end,
	score=function(P)return{P.modeData.point<=100 and P.modeData.point or 100,P.stat.time}end,
	scoreDisp=function(D)return D[1].." Combo   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.row
		if L==100 then
			local T=P.stat.time
			return
			T<=30 and 5 or
			T<=50 and 4 or
			T<=80 and 3 or
			2
		else
			return
			L>=60 and 2 or
			L>=30 and 1 or
			L>=10 and 0
		end
	end,
}