Tmr={}
function Tmr.load()
	if loading==1 then
		loadnum=loadnum+1
		loadprogress=loadnum/10
		if loadnum==5 then
			--require("load_texture")
		elseif loadnum==10 then
			loadnum=1
			loading=2
		end
	elseif loading==2 then
		if loadnum<=#bgm then
			bgm[bgm[loadnum]]=love.audio.newSource("/BGM/"..bgm[loadnum]..".ogg","stream")
			bgm[bgm[loadnum]]:setLooping(true)
			loadprogress=loadnum/#bgm
			loadnum=loadnum+1
		else
			for i=1,#bgm do bgm[i]=nil end
			loading=3
			loadnum=1
		end
	elseif loading==3 then
		if loadnum<=#sfx then
			sfx[sfx[loadnum]]=love.audio.newSource("/SFX/"..sfx[loadnum]..".ogg","static")
			loadprogress=loadnum/#sfx
			loadnum=loadnum+1
		else
			for i=1,#sfx do sfx[i]=nil end
			loading=4
			loadnum=1
		end
	elseif loading==4 then
		loadnum=loadnum+1
		if loadnum==20 then
			gotoScene("main")
		end
	end
end
function Tmr.play(dt)
	frame=frame+1
	if count then
		count=count-1
		if count==0 then
			count=nil
			SFX("start")
			for P=1,#players do
				P=players[P]
				_G.P=P
				setmetatable(_G,P.index)
				P.control=true
				resetblock()
			end
			setmetatable(_G,nil)
		elseif count%60==0 then
			SFX("ready")
		end
		return nil
	end
	for p=1,#players do
		P=players[p]
		setmetatable(_G,P.index)
		if alive then
			if control then P.time=time+dt end

			local v=0
			for i=2,10 do v=v+i*(i-1)*7.2/(frame-keyTime[i])end P.keySpeed=keySpeed*.99+v*.1
			v=0 for i=2,10 do v=v+i*(i-1)*7.2/(frame-dropTime[i])end P.dropSpeed=dropSpeed*.99+v*.1
			--Update speeds

			if P.ai then
				P.ai.controlDelay=P.ai.controlDelay-1
				if P.ai.controlDelay==0 then
					if #P.ai.controls>0 then
						pressKey(P.ai.controls[1],P)
						releaseKey(P.ai.controls[1],P)
						rem(P.ai.controls,1)
						P.ai.controlDelay=P.ai.controlDelay0+rnd(3)
					else
						AI_getControls(P.ai.controls)
						P.ai.controlDelay=2*P.ai.controlDelay0
					end
				end
			end

			for j=1,#field do for i=1,10 do
				if visTime[j][i]>0 then P.visTime[j][i]=visTime[j][i]-1 end
			end end
			--Fresh visible time
			if keyPressing[1]or keyPressing[2]then
				P.moving=moving+sgn(moving)
				local d=abs(moving)-gameEnv.das
				if d>1 then
					if gameEnv.arr>0 then
						if d%gameEnv.arr==0 then
							act[moving>0 and"moveRight"or"moveLeft"](true)
						end
					else
						act[moving>0 and"toRight"or"toLeft"]()
					end
				end
			else
				P.moving=0
			end
			if keyPressing[7]then
				act.softDrop()
				P.downing=downing+1
			else
				P.downing=0
			end
			if falling>0 then
				P.falling=falling-1
				if falling<=0 then
					if #field>clearing[1]then SFX("fall")end
					for i=1,#clearing do
						rem(field,clearing[i])
						rem(visTime,clearing[i])
					end
					P.clearing={}
				end
			elseif waiting>0 then
				P.waiting=waiting-1
				if waiting<=0 then
					resetblock()
				end
			else
				if cy~=y_img then
					if dropDelay>1 then
						P.dropDelay=dropDelay-1
					else
						drop()
						P.dropDelay,P.lockDelay=gameEnv.drop,gameEnv.lock
					end
				else
					if lockDelay>0 then P.lockDelay=lockDelay-1
					else drop()
					end
				end
			end
		end--If alive
		for i=#bonus,1,-1 do
			bonus[i].t=bonus[i].t+1
			if bonus[i].t>60 then rem(bonus,i)end
		end
		for i=#task,1,-1 do
			if task[i]()then rem(task,i)end
		end
		for i=#atkBuffer,1,-1 do
			local atk=atkBuffer[i]
			atk.time=atk.time+1
			if not atk.sent then
				if atk.countdown>0 then
					atk.countdown=atk.countdown-1
				end
			else
				if atk.time>20 then
					rem(atkBuffer,i)
				end
			end
		end
		if fieldBeneath>0 then P.fieldBeneath=fieldBeneath-2 end
		PTC.dust[p]:update(dt)
	end
	for i=#FX.beam,1,-1 do
		FX.beam[i].t=FX.beam[i].t+1
		if FX.beam[i].t>30 then
			rem(FX.beam,i)
		end
	end
	setmetatable(_G,nil)
end