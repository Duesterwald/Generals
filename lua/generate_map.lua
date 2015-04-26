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
			local tstring = wesnoth.get_terrain(v.x, v.y)
			if tstring == nil then tstring = "Xv" end
			surrounding_terrain[u] = Terrain.new(tstring)
		end
	end

	local map = Map.new(map_dim)

	local super_hexes = HexVecSet.new()
	for u, terrain in surrounding_terrain() do
		super_hexes[u] = HexVecSet.super_hex(u, map_size, terrain)
	end

	local processed_edge = HexVecSet.new()
	local feats = {}
	for u, t in surrounding_terrain() do
		local up = t:get_class().pressure
		local v = local2global[u]
		local us = super_hexes[u]
		for i = 1, 6 do
			local au, av = u + keep_conn[i], v + adjacent_offset[i]
			if not processed_edge[av + v] then
				local function edge_ran() return ran((av + v)/2) end

				local at, as = surrounding_terrain[au], super_hexes[au]
				-- If adjacent tile is not included in the map, create it temporarily
				if at == nil then
					at = wesnoth.get_terrain(av.x, av.y)
					if at == nil then at = "Xv" end
					at = Terrain.new(at)
					as = HexVecSet.super_hex(au, map_size, at)
				end

				local ap = at:get_class().pressure
				local thresh = up / (up + ap)
				local length = map_size * map_size / (up + ap) / 5
				-- For each overlapping tile, create a feature
				for x in (us * as)() do
					local strong, weak = {u,t,up * length}, {au,at,ap * length}
					if edge_ran() > thresh  then strong, weak = weak, strong end

					feats[#feats+1] = { strong[1], weak[1], feature(edge_ran, x, strong[3], correlation(dir(weak[1] - x), 4, -3), strong[2]) }
				end
				processed_edge[av + v] = true
			end
		end
	end

	for void, feat in pairs(feats) do
		if super_hexes[feat[1]] ~= nil then super_hexes[feat[1]]:add(feat[3]) end
		if super_hexes[feat[2]] ~= nil then super_hexes[feat[2]]:subtract(feat[3]) end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local rv = function () return ran(v) end
		local tclass = terrain:get_class()

		-- Create some mountains
		for void = 1, math.ceil(ran(v) * #super_hexes[u] * tclass.mountain_density / 500) do
			local r,height,tind,start,f = ran(v), nil
			height,r = ran_int(r, 2)
			tind,r = ran_int(r, #tclass.mountain)
			local mterrain = Terrain.new(tclass.mountain[tind])
			local hterrain = Terrain.new(tclass.hill[tind])
			start,r = super_hexes[u]:random_hex(r)
			local bdc = {}
			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
			local corr = correlation(bdc[1], bdc[2], bdc[3])
			local length = math.ceil(r * tclass.mountain_size * map_size)
			if height == 2 then
				f = feature(rv, start, length, corr, mterrain)
				f = f:border(hterrain, true)
			else
				f =feature(rv, start, length, corr, hterrain)
			end
			super_hexes[u]:insert(f)
		end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local rv = function () return ran(v) end
		local tclass = terrain:get_class()

		for void = 1, math.ceil(ran(v) * #super_hexes[u] * tclass.flat_density / 500) do
			local r,tind,start,f = ran(v), nil
			tind,r = ran_element(r, tclass.flat)
			tind = Terrain.new(tind)
			start,r = super_hexes[u]:random_hex(r)
			local bdc = {}
			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
			local corr = correlation(bdc[1], bdc[2], bdc[3])
			local length = math.ceil(r * tclass.flat_size * map_size)
			local f = feature(rv, start, length, corr, tind)
			super_hexes[u]:insert(f)
		end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local rv = function () return ran(v) end
		local tclass = terrain:get_class()

		for void = 1, math.ceil(ran(v) * #super_hexes[u] * tclass.forest_density / 500) do
			local r,tind,start,f = ran(v), nil
			tind,r = ran_element(r, tclass.forest)
			start,r = super_hexes[u]:random_hex(r)
			local bdc = {}
			for i = 1,3 do bdc[i],r = ran_int(r, 6) end
			local corr = correlation(bdc[1], bdc[2], bdc[3])
			local length = math.ceil(r * tclass.forest_size * map_size)
			local f = feature(rv, start, length, corr, tind)
			super_hexes[u]:insert(f, function(ut, ft) return Terrain.new(ut:get_base()..ft) end)
		end
	end

	for void, super_hex in super_hexes() do
		for u, terrain in super_hex() do
			map:set_code(u, terrain:get_base()..terrain:get_overlay())
		end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local rv = function () return ran(v) end
		local tclass = terrain:get_class()

		local kt,ct = terrain:get_keep_and_castle(ran(v))
		local keep_set = feature(rv, u, keep_size + 1, correlation(nil, nil, -2), ct)
		keep_set[u] = kt
		local village_block = keep_set:border('Ww', true)

		-- Build the roads
		if #tclass.road > 0 then
			local rterrain = ran_element(ran(v), tclass.road)
			local rvecs =
			{
				{adjacent_offset[2], adjacent_offset[1] + adjacent_offset[6], adjacent_offset[6]},
				{adjacent_offset[4], adjacent_offset[3] + adjacent_offset[2], adjacent_offset[2]},
				{adjacent_offset[6], adjacent_offset[5] + adjacent_offset[4], adjacent_offset[4]}
			}
			for void, rvec in ipairs(rvecs) do
				local target = rvec[1] * map_size + rvec[2] * math.floor(map_size / 3)
				if map_size % 3 == 2 then target = target + rvec[3] end
				local rd = road(rv, u, target, round(tclass.road_windedness * map_size),rterrain)
				for rpos, rt in rd() do
					map:set_code(rpos, rt)
					village_block[rpos] = rt
				end
			end
		end

		for void = 1, math.ceil(hex_area * tclass.castle_density / 500) do
			local r = ran(v)
			local pos = nil
			pos = super_hexes[u]:random_hex(r)
			if not village_block:contains(pos) then map:set_code(pos, ct) end
		end

		local villages = HexVecSet.new()
		if terrain:is_town() then
			for pos, postrn in super_hexes[u]() do
				if ran(v) * map_size  * tclass.village_density_factor > (pos - u).length and
					not village_block:contains(pos) and postrn:get_class() == tclass then
					villages[pos] = terrain:get_village()
				end
			end
		else
			while #villages < math.ceil(num_villages * tclass.village_density_factor) do
				local pos = u + random_position(ran(v), map_size)
				if not village_block:contains(pos) then
					local vill = ""
					if map:contains(pos) then vill = map[pos]:get_village(ran(v)) end
					villages[pos] = vill
				end
			end
		end
		for vil_pos, vil_ov in villages() do map:set_overlay(vil_pos, vil_ov) end

		for kpos, kt in keep_set() do
			map:set_code(kpos, kt)
		end
	end

	wesnoth.set_variable("local_map", tostring(map))
	wesnoth.set_variable("GN_ATTACKER_X", keep[1].x)
	wesnoth.set_variable("GN_ATTACKER_Y", keep[1].y)
	wesnoth.set_variable("GN_DEFENDER_X", keep[2].x)
	wesnoth.set_variable("GN_DEFENDER_Y", keep[2].y)
>>

