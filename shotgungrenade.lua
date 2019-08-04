if not shotgun then shotgun = {} end

shotgun.func = {
	extendposition = function(x, y, dist, dir)
		return x + math.sin(math.rad(dir)) * dist, y - math.cos(math.rad(dir)) * dist
	end;
	
	getdistance = function(x1, y1, x2, y2)
		return math.sqrt((y1 - y2)^2 + (x1 - x2)^2)
	end;
	
	createprojectile = function(player, img, speed, x, y, dir, livedist)
		local tbl = {
			image = image(img, x, y, 1);
			player = player;
			speed = speed;
			x = x;
			y = y;
			dir = dir;
			rot = dir;
			livedist = livedist;
		}
		table.insert(shotgun.projectile, tbl)
	end
}

shotgun.projectile = {}

addhook('attack', 'shotgun.hook.attack')
addhook('always', 'shotgun.hook.always')
addhook('clientdata', 'shotgun.hook.clientdata')
addhook('startround', 'shotgun.hook.startround')

shotgun.hook = {
	attack = function(id)
		if player(id, 'weapontype') == 11 then
			reqcld(id, 2)
		end
	end;
	
	always = function()
		for k, v in pairs(shotgun.projectile) do
			v.x, v.y = shotgun.func.extendposition(v.x, v.y, v.speed, v.dir)
			v.rot = v.rot + 10
			if v.rot > 180 then v.rot = -180 end
			imagepos(v.image, v.x, v.y, v.rot)
			tween_rotateconstantly(v.image, 2)
			local lastdir = v.dir
			if tile(math.floor(v.x / 32), math.floor(v.y / 32), "wall") then
				v.dir = -v.dir
				local nx, ny = shotgun.func.extendposition(v.x, v.y, v.speed, v.dir)
				if tile(math.floor(nx / 32), math.floor(ny / 32), "wall") then
					v.dir = v.dir + 180
				end
				repeat
					v.x, v.y = shotgun.func.extendposition(v.x, v.y, -1, lastdir)
				until not tile(math.floor(v.x / 32), math.floor(v.y / 32), "wall")
				imagepos(v.image, v.x, v.y, v.rot)
			end
			v.livedist = v.livedist - v.speed
			if v.livedist <= 0 then
				parse('explosion '.. v.x ..' '.. v.y ..' 50 100 '.. v.player)
				freeimage(v.image)
				table.remove(shotgun.projectile, k)
			end
		end
	end;
	
	clientdata = function(id, mode, data1, data2)
		for i = 1, 5 do
			shotgun.func.createprojectile(id, "gfx/weapons/grenade.bmp<m>", 7, player(id, 'x'), player(id, 'y'), math.random(player(id, 'rot') - 15, player(id, 'rot') + 15), shotgun.func.getdistance(player(id, 'x'), player(id, 'y'), data1, data2))
		end
	end;
	
	startround = function()
		shotgun.projectile = {}
	end;
}