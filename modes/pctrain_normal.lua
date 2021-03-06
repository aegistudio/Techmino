local rnd=math.random
local ins=table.insert
local PCbase=require("parts/PCbase")
local PClist=require("parts/PClist")
local function task_PC(P)
	local _
	P.modeData.counter=P.modeData.counter+1
	if P.modeData.counter==21 then
		local t=P.stat.pc%2
		local S=P.gameEnv.skin
		for i=1,4 do
			local r=freeRow.get(0)
			for j=1,10 do
				_=PCbase[4*t+i][j]
				r[j]=S[_]or 0
			end
			ins(P.field,1,r)
			ins(P.visTime,1,freeRow.get(20))
		end
		P.fieldBeneath=P.fieldBeneath+120
		P.curY=P.curY+4
		P:freshgho()
		return true
	end
end
local function newPC(P)
	local r=P.field;r=r[#r]
	if r then
		local c=0
		for i=1,10 do if r[i]>0 then c=c+1 end end
		if c<5 then
			P:lose()
		end
	end
	if P.stat.piece%4==0 and #P.field==0 then
		P.modeData.event=P.modeData.event==0 and 1 or 0
		local r=rnd(#PClist)
		local f=P.modeData.event==0
		for i=1,4 do
			local b=PClist[r][i]
			if f then
				if b<3 then b=3-b
				elseif b<5 then b=7-b
				end
			end
			P:getNext(b)
		end
		P.modeData.counter=P.stat.piece==0 and 20 or 0
		TASK.new(task_PC,P)
	end
end
return{
	color=color.green,
	env={
		next=4,
		hold=false,
		drop=150,lock=150,
		fall=20,
		sequence="none",
		dropPiece=newPC,
		ospin=false,
		bg="rgb",bgm="oxygen",
	},
	pauseLimit=true,
	load=function()
		newPlayer(1,340,15)
		newPC(players[1])
	end,
	mesDisp=function(P,dx,dy)
		setFont(75)
		mStr(P.stat.pc,-81,330)
		mText(drawableText.pc,-81,412)
	end,
	score=function(P)return{P.stat.pc,P.stat.time}end,
	scoreDisp=function(D)return D[1].." PCs   "..toTime(D[2])end,
	comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
	getRank=function(P)
		local L=P.stat.pc
		return
		L>=100 and 5 or
		L>=60 and 4 or
		L>=40 and 3 or
		L>=25 and 2 or
		L>=15 and 1 or
		L>=1 and 0
	end,
}