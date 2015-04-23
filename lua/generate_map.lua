<<
	local a = ...

	local location = { HexVec.new(a.x1, a.y1), HexVec.new(a.x2, a.y2) }

	local atkdir = location[2] - location[1]

	local keep_offset, map_center, map_dim = nil
	local dy = round(2 + map_size/3)

	if atkdir[1] == 0 then
		keep_offset = HexVec.new(round(1 + 4/3*map_size), dy)
		map_center = (adjacent_offset[4] * map_size) + keep_offset
		map_dim = HexVec.new(2*keep_offset.x - 1, 2*map_center.y -1)
	else
		keep_offset = HexVec.new( round(dy/0.866), dy)
		map_center = (adjacent_offset[3] * map_size) + keep_offset
		map_dim = HexVec.new(map_center.x*2-1, dy*2-1 + map_size)
	end

	-- needs map_dim
	local seed = global_map_size[1] * 8363 * global_map_size[2] + global_map_size[2] * 91
	local seed_store = HexVecSet.new()

	local function ran(v)
		if seed_store[v] == nil then
			seed_store[v] = seed * (v[1] * 7369 + v[2])
		end
		seed_store[v] = (seed_store[v] * 1103515245 + 12345) % 2147483648
		return seed_store[v]/2147483648
	end

	local keep = { map_center - atkdir * map_size, map_center + atkdir * map_size }

	local surrounding_terrain = HexVecSet.new()
	local local2global = HexVecSet.new()
	local global2local = HexVecSet.new()
	for i = 1,2 do
		for j = 1,6 do
			local u = keep[i] + keep_conn[j]
			local v = location[i] + adjacent_offset[j]
			global2local[v] = u
			local2global[u] = v
			surrounding_terrain[u] = Terrain.new(wesnoth.get_terrain(v.x, v.y))
		end
	end

	local map = Map.new(map_dim)
	for x = 0, map.x do
		for y = 0, map.y do
			local min_dis = 4 * map_size
			for u, terrain in surrounding_terrain() do
				local pos = HexVec.new(x, y)
				local dis = ( pos - u ).length
				if dis <= min_dis then
					map:set_code(pos, terrain:get_base())
					min_dis = dis
				end
			end
		end
	end

	local function feature(global_position, local_position, length, correlation, terrain)
		local f = HexVecSet.new()
		local start = HexVec.new(local_position)
		f[start] = terrain
		local last_dir = 0
		while #f < length do
			local r = ran(global_position) * correlation[last_dir].sum
			for i = 1,6 do
				r = r - correlation[last_dir][i]
				if r <= 0 then
					last_dir = i
					break
				end
			end
			repeat
				start = start + adjacent_offset[last_dir]
			until f[start] == nil
			f[start] = terrain
		end
		return f
	end

	local function road(global_position, origin, diff, deviations, terrain)
		if diff.length < deviations then error("road(): deviations must be less than diff.length!") end
		print("road ",global_position, origin, diff, deviations, terrain)
		local res = HexVecSet.new()
		local start = HexVec.new(origin)
		res[start] = terrain
		if diff[1] == 0 and diff[2] == 0 then return res end

		-- find out how many steps in which direction must be taken to get from start
		-- to finish
		local dirs = { 0, 0, 0, 0, 0, 0}
		if diff[1]*diff[2] < 0 then
			if diff[1] > 0 then
				dirs[2] = math.min(diff[1], -diff[2])
				if diff[1] > -diff[2] then
					dirs[3] = diff[1] + diff[2]
				else
					dirs[1] = -diff[2] - diff[1]
				end
			else
				dirs[5] = math.min(-diff[1], diff[2])
				if -diff[1] < diff[2] then
					dirs[4] = diff[2] + diff[1]
				else
					dirs[6] = -diff[1] - diff[2]
				end
			end
		else
			-- one of them might be zero. Therefore the sum is compared to 0.
			if diff[1] + diff[2] > 0 then dirs[3], dirs[4] = diff[1], diff[2]
			else dirs[6], dirs[1] = -diff[1], -diff[2]
			end
		end

		local cdir = 1
		-- add some deviations
		for cdir = 1, 6 do
			if dirs[cdir] > 0 then
				if dirs[left_to(cdir)] ~= 0 then cdir = left_to(cdir) end
				dirs[left_to(cdir)] = deviations
				if dirs[right_to(cdir)] == 0 then
					dirs[cdir] = dirs[cdir] - deviations
				else
					cdir = right_to(cdir)
				end
				dirs[right_to(cdir)] = deviations
				break
			end
		end
		
		for i, num in ipairs(dirs) do
			for void = 1, num do
				start = start + adjacent_offset[i]
				res[start] = terrain
			end
		end

		print("road finished")
		return res
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local tclass = terrain:get_class()

		-- Create some mountains
--		for void = 1, math.ceil(ran(v) * hex_area * tclass.mountain_density / 500) do
--			local r,height,tind,start,f = ran(v), nil
--			height,r = ran_int(r, 2)
--			tind = ran_element(r, tclass.mountain)
--			start,r = random_position(r, map_size)
--			start = start + u
--			local bdc = {}
--			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
--			local corr = correlation(bdc[1], bdc[2], bdc[3])
--			local length = math.ceil(r * tclass.mountain_size * map_size)
--			if height == 2 then
--				f = feature(v, start, length, corr, tind)
--				f = f:border(tind, true)
--			else
--				f =feature(v, start, length, corr, tind)
--			end
--			for mpos,mt in f() do map:set_code(mpos, mt) end
--		end
--
--		for void = 1, math.ceil(ran(v) * hex_area * tclass.flat_density / 500) do
--			local r,tind,start,f = ran(v), nil
--			tind = ran_element(r, tclass.flat)
--			start,r = random_position(r, map_size)
--			start = start + u
--			local bdc = {}
--			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
--			local corr = correlation(bdc[1], bdc[2], bdc[3])
--			local length = math.ceil(r * tclass.flat_size * map_size)
--			local f = feature(v, start, length, corr, tind)
--			for fpos, ft in f() do map:set_base(fpos, ft) end
--		end
--
--		for void = 1, math.ceil(ran(v) * hex_area * terrain:get_forest_density() / 500) do
--			local r,tind,start,f = ran(v), nil
--			tind,r = ran_element(r, tclass.forest)
--			start,r = random_position(r, map_size)
--			start = start + u
--			local bdc = {}
--			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
--			local corr = correlation(bdc[1], bdc[2], bdc[3])
--			local length = math.ceil(r * tclass.forest_size * map_size)
--			local f = feature(v, start, length, corr, tind)
--			for fpos, ft in f() do
--				map:set_overlay(fpos, ft)
--			end
--		end

		local kt,ct = terrain:get_keep_and_castle(ran(v))
		local keep_set = feature(v, u, keep_size + 1, correlation(nil, nil, -2), ct)
		keep_set[u] = kt
		local village_block = keep_set:border('Ww', true)

		-- Build the roads
		local rvecs =
		{
			{adjacent_offset[2], adjacent_offset[1] + adjacent_offset[6], adjacent_offset[6]},
			{adjacent_offset[4], adjacent_offset[3] + adjacent_offset[2], adjacent_offset[2]},
			{adjacent_offset[6], adjacent_offset[5] + adjacent_offset[4], adjacent_offset[4]}
		}
		for void, rvec in ipairs(rvecs) do
			local target = rvec[1] * map_size + rvec[2] * math.floor(map_size / 3)
			if map_size % 3 == 2 then target = target + rvec[3] end
			print("target "..void.." = "..tostring(target))
			local rd = road(v, u, target, 0, "Rr")
			for rpos, rt in rd() do
				map:set_code(rpos, rt)
				village_block[rpos] = rt
			end
		end

--		for void = 1, math.ceil(hex_area * tclass.castle_density / 500) do
--			local r = ran(v)
--			local pos = nil
--			pos = u + random_position(r, map_size)
--			if not village_block:contains(pos) then map:set_code(pos, ct) end
--		end
--
--		local villages = HexVecSet.new()
--		while #villages < math.ceil(num_villages * tclass.village_density_factor) do
--			local r = ran(v)
--			local pos= nil
--			pos, r = random_position(r, map_size)
--			pos = u + pos
--			if not village_block:contains(pos) then
--				local vill = ""
--				if map:contains(pos) then vill, r = map[pos]:get_village(r) end
--				villages[pos] = vill
--			end
--		end
--		for vil_pos, vil_ov in villages() do map:set_overlay(vil_pos, vil_ov) end
--
--		for kpos, kt in keep_set() do
--			map:set_code(kpos, kt)
--		end
	end

	wesnoth.set_variable("local_map", tostring(map))
	wesnoth.set_variable("GN_ATTACKER_X", keep[1].x)
	wesnoth.set_variable("GN_ATTACKER_Y", keep[1].y)
	wesnoth.set_variable("GN_DEFENDER_X", keep[2].x)
	wesnoth.set_variable("GN_DEFENDER_Y", keep[2].y)
>>

