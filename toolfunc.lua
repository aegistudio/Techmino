function string.splitS(s,sep)
	local t={}
	repeat
		local i=find(s,sep)or #s+1
		ins(t,sub(s,1,i-1))
		s=sub(s,i+#sep)
	until #s==0
	return t
end
function sgn(i)return i>0 and 1 or i<0 and -1 or 0 end--Row numbe is A-uth-or's id!
function stringPack(s,v)return s..toS(v)end
function without(t,v)
	for i=1,#t do
		if t[i]==v then return nil end
	end
	return true
end
function mStr(s,x,y)
	gc.printf(s,x-500,y,1000,"center")
end
function convert(x,y)
	return xOy:inverseTransformPoint(x,y)
end

function getNewRow(val)
	if not val then val=0 end
	local t=rem(freeRow)
	for i=1,10 do
		t[i]=val or 0
	end
	--clear a row and move to active list
	if #freeRow==0 then
		for i=1,20 do
			ins(freeRow,{0,0,0,0,0,0,0,0,0,0})
		end
	end
	--prepare new rows
	return t
end
function removeRow(t,k)
	ins(freeRow,rem(t,k))
end

local count=0
BGblockList={}for i=1,16 do BGblockList[i]={v=0}end
function getNewBlock()
	count=count+1
	if count==17 then count=1 end
	local t=BGblockList[count]
	t.bn,t.size=BGblock.next,2+3*rnd()
	t.b=blocks[t.bn][rnd(0,3)]
	t.x=rnd(-#t.b[1]*t.size*30+100,1180)
	t.y=-#t.b*30*t.size
	t.v=t.size*(1+rnd())
	BGblock.next=BGblock.next%7+1
	return t
end

function timeSort(a,b)
	return a.time>b.time
end
function stencil_field()
	gc.rectangle("fill",0,-10,300,610)
end
function stencil_field_small()
	gc.rectangle("fill",0,0,300,600)
end
--Single use

function sysSFX(s,v)
	if setting.sfx then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
			end
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function SFX(s,v)
	if setting.sfx and not P.ai then
		local n=1
		while sfx[s][n]:isPlaying()do
			n=n+1
			if not sfx[s][n]then
				sfx[s][n]=sfx[s][n-1]:clone()
				sfx[s][n]:seek(0)
				break
			end
		end
		sfx[s][n]:setVolume(v or 1)
		sfx[s][n]:play()
	end
end
function BGM(s)
	if setting.bgm and bgmPlaying~=s then
		for k,v in pairs(bgm)do v:stop()end
		if s then bgm[s]:play()end
		bgmPlaying=s
	end
end
function gotoScene(s,style)
	if not sceneSwaping and s~=scene then
		style=style or"deck"
		sceneSwaping={
			tar=s,style=style,
			time=swap[style][1],mid=swap[style][2],
			draw=swap[style].d
		}
		Buttons.sel=nil
	end
end
function startGame(mode)
	--rec=""
	gamemode=mode
	gotoScene("play")
end
function back()
	local t=prevMenu[scene]
	if type(t)=="string"then
		gotoScene(t)
	else
		t()
	end
end
function loadData()
	userData:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userData:read(),"\r\n")
	userData:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="run"or t=="game"or t=="gametime"or t=="piece"or t=="row"or t=="atk"or t=="key"or t=="rotate"or t=="hold"or t=="spin"then
				v=toN(v)if not v or v<0 then v=0 end
				stat[t]=v
			end
		end
	end
end
function saveData()
	local t=table.concat({
		stringPack("run=",stat.run),
		stringPack("game=",stat.game),
		stringPack("gametime=",stat.gametime),
		stringPack("piece=",stat.piece),
		stringPack("row=",stat.row),
		stringPack("atk=",stat.atk),
		stringPack("key=",stat.key),
		stringPack("rotate=",stat.rotate),
		stringPack("hold=",stat.hold),
		stringPack("spin=",stat.spin),
	},"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userData:open("w")
	userData:write(t)
	userData:close()
end
function loadSetting()
	userSetting:open("r")
    --local t=string.splitS(love.math.decompress(userdata,"zlib"),"\r\n")
	local t=string.splitS(userSetting:read(),"\r\n")
	userSetting:close()
	for i=1,#t do
		local i=t[i]
		if find(i,"=")then
			local t=sub(i,1,find(i,"=")-1)
			local v=sub(i,find(i,"=")+1)
			if t=="sfx"or t=="bgm"then
				setting[t]=v=="true"
			elseif t=="fullscreen"then
				setting.fullscreen=v=="true"
				love.window.setFullscreen(setting.fullscreen)
			elseif t=="bgblock"then
				setting.bgblock=v=="true"
			elseif t=="keymap"then
				v=string.splitS(v,"/")
				for i=1,16 do
					local v1=string.splitS(v[i],",")
					for j=1,#v1 do
						setting.keyMap[i][j]=v1[j]
					end
				end
			elseif t=="keylib"then
				v=string.splitS(v,"/")
				for i=1,4 do
					local v1=string.splitS(v[i],",")
					for j=1,#v1 do
						setting.keyLib[i][j]=toN(v1[j])
					end
					for j=1,#setting.keyLib[i]do
						local v=setting.keyLib[i][j]
						if int(v)~=v or v>=9 or v<=0 then
							setting.keyLib[i]={i}
							break
						end
					end
				end
			elseif t=="virtualkey"then
				v=string.splitS(v,"/")
				for i=1,9 do
					virtualkey[i]=string.splitS(v[i],",")
					for j=1,4 do
						virtualkey[i][j]=toN(virtualkey[i][j])
					end
				end
			elseif t=="virtualkeyAlpha"then
				setting.virtualkeyAlpha=int(abs(toN(v)))
			elseif t=="virtualkeyIcon"then
				setting.virtualkeyIcon=v=="true"
			elseif t=="virtualkeySwitch"then
				setting.virtualkeySwitch=v=="true"
			elseif t=="frameMul"then
				v=min(max(toN(v)or 100,0),100)
				setting.frameMul=v
			elseif t=="das"or t=="arr"or t=="sddas"or t=="sdarr"then
				v=toN(v)if not v or v<0 then v=0 end
				setting[t]=int(v)
			elseif t=="ghost"or t=="center"then
				setting[t]=v=="true"
			end
		end
	end
end
function saveSetting()
	local vk={}
	for i=1,9 do
		for j=1,4 do
			virtualkey[i][j]=int(virtualkey[i][j]+.5)
		end--Saving a integer is better?
		vk[i]=table.concat(virtualkey[i],",")
	end--pre-pack virtualkey setting
	local map={}
	for i=1,16 do
		map[i]=table.concat(setting.keyMap[i],",")
	end
	local lib={}
	for i=1,4 do
		lib[i]=table.concat(setting.keyLib[i],",")
	end
	local t=table.concat({
		stringPack("sfx=",setting.sfx),
		stringPack("bgm=",setting.bgm),
		stringPack("fullscreen=",setting.fullscreen),
		stringPack("bgblock=",setting.bgblock),
		stringPack("das=",setting.das),
		stringPack("arr=",setting.arr),
		stringPack("sddas=",setting.sddas),
		stringPack("sdarr=",setting.sdarr),
		stringPack("keymap=",table.concat(map,"/")),
		stringPack("keylib=",table.concat(lib,"/")),
		stringPack("virtualkey=",table.concat(vk,"/")),
		stringPack("virtualkeyAlpha=",setting.virtualkeyAlpha),
		stringPack("virtualkeyIcon=",setting.virtualkeyIcon),
		stringPack("virtualkeySwitch=",setting.virtualkeySwitch),
		stringPack("frameMul=",setting.frameMul),
	},"\r\n")
	--t=love.math.compress(t,"zlib"):getString()
	userSetting:open("w")
	userSetting:write(t)
	userSetting:close()
end