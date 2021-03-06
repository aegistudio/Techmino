local rem=table.remove

local tasks={}

local TASK={}
function TASK.getCount()
	return #tasks
end
function TASK.update()
	for i=#tasks,1,-1 do
		local T=tasks[i]
		if T.code(T.P,T.data)then
			for i=i,#tasks do
				tasks[i]=tasks[i+1]
			end
 		end
	end
end
function TASK.new(code,P,data)
	tasks[#tasks+1]={
		code=code,
		P=P,
		data=data,
	}
end
function TASK.changeCode(c1,c2)
	for i=#tasks,1,-1 do
		if tasks[i].code==c1 then
			tasks[i].code=c2
		end
	end
end
function TASK.removeTask_code(code)
	for i=#tasks,1,-1 do
		if tasks[i].code==code then
			rem(tasks,i)
		end
	end
end
function TASK.removeTask_data(data)
	for i=#tasks,1,-1 do
		if tasks[i].data==data then
			rem(tasks,i)
		end
	end
end
function TASK.clear(opt)
	if opt=="all"then
		local i=#tasks
		while i>0 do
			tasks[i]=nil
			i=i-1
		end
	elseif opt=="play"then
		for i=#tasks,1,-1 do
			if tasks[i].P then
				rem(tasks,i)
			end
		end
	else--Player table
		for i=#tasks,1,-1 do
			if tasks[i].P==opt then
				rem(tasks,i)
			end
		end
	end
end
return TASK