return{
	color=color.white,
	env={
		drop=60,lock=60,
		freshLimit=15,
		bg="none",bgm="way",
	},
	load=function()
		newPlayer(1,20,15)
		newPlayer(2,650,15)
	end,
	mesDisp=function(P,dx,dy)
	end,
}