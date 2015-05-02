<<
	local a = ...

	local location = { HexVec.new(a.x1, a.y1), HexVec.new(a.x2, a.y2) }

	local atkdir = location[2] - location[1]

	local map_center, map_dim = nil
	local dy = round(2 + map_size/3)

	if atkdir[1] == 0 then
		local keep_offset = HexVec.new(round(1 + 4/3*map_size), dy)
		map_center = (adjacent_offset[4] * map_size) + keep_offset
		map_dim = HexVec.new(2*keep_offset.x - 1, 2*map_center.y -1)
	else
		local keep_offset = HexVec.new( round(dy/0.866), dy)
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
		return (seed_store[v]%1073741824)/1073741824
	end

	local keep = { map_center - atkdir * map_size, map_center + atkdir * map_size }

	local surrounding_terrain = HexVecSet.new()
	local super_hexes = HexVecSet.new()
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
			super_hexes[u] = HexVecSet.super_hex(u, map_size, Terrain.new(surrounding_terrain[u]:get_base()))
		end
	end

	local map = Map.new(map_dim)

	local processed_edge = HexVecSet.new()
	local feats = {}
	for uu, ut in surrounding_terrain() do
		local u = { uu }
		local p = { ut:get_class().pressure }
		local v = { local2global[uu] }
		local s = { super_hexes[uu] }
		local t = { Terrain.new(ut:get_base()) }
		for k = 1, 6 do
			u[2], v[2] = u[1] + keep_conn[k], v[1] + adjacent_offset[k]
			if not processed_edge[v[1] + v[2]] then
				local function edge_ran() return ran((v[1] + v[2])/2) end

				t[2], s[2] = surrounding_terrain[u[2]], super_hexes[u[2]]
				-- If adjacent tile is not included in the map, create it temporarily
				if t[2] == nil then
					t[2] = wesnoth.get_terrain(v[2].x, v[2].y)
					if t[2] == nil then t[2] = "Xv" end
					t[2] = Terrain.new(t[2])
					s[2] = HexVecSet.super_hex(u[2], map_size, t[2])
				end
				p[2] = t[2]:get_class().pressure
				local length = map_size * map_size / (p[1] + p[2]) / 5
				local strong, weak = 1, 2
				if p[strong] < p[weak] then strong, weak = 2, 1 end
				local thresh = p[strong] / (p[weak] + p[strong])
				-- For each overlapping tile, create a feature
				for x in (s[1] * s[2])() do
					local i,j = strong, weak
					if edge_ran() > thresh then i,j = weak,strong end
					feats[#feats+1] = { u[i], u[j], feature(edge_ran, x, p[i]*length, correlation(dir(u[j] - x), 4, -3), t[1]) }
				end
				processed_edge[v[1] + v[2]] = true
			end
		end
	end

	-- Add and subtract separately for stability
	for void, feat in pairs(feats) do
		if super_hexes[feat[2]] ~= nil then super_hexes[feat[2]]:subtract(feat[3]) end
	end
	for void, feat in pairs(feats) do
		if super_hexes[feat[1]] ~= nil then super_hexes[feat[1]]:add(feat[3]) end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		local rv = function () return ran(v) end
		local tclass = terrain:get_class()

		local ofeats = surrounding_terrain[u]:get_overlay_features(rv, u)
		for void, feat in ipairs(ofeats.full) do super_hexes[u]:insert(feat) end
		for void, feat in ipairs(ofeats.base) do super_hexes[u]:insert(feat, function(t,n) t:set_base(n) return t end) end
		for void, feat in ipairs(ofeats.overlay) do super_hexes[u]:insert(feat, function(t,n) return Terrain.new(t:get_base()..n) end) end

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

		-- create some flat patches
		for void = 1, math.ceil(ran(v) * #super_hexes[u] * tclass.flat_density / 500) do
			local r,tind,start,f = ran(v), nil
			tind,r = ran_element(r, tclass.flat)
			tind = Terrain.new(tind)
			start,r = super_hexes[u]:random_hex(r)
			local corr = correlation(ran(v)*6, 2 + ran(v) * 4, ran(v)*12 - 6)
			local length = math.ceil(r * tclass.flat_size * map_size)
			local f = feature(rv, start, length, corr, tind)
			super_hexes[u]:insert(f)
		end

		-- create some forests
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
			map:set_code(u, terrain:get_code())
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

		for kb in keep_set:border(0)() do
			if map:contains(kb) then map:set_base(kb, map[kb]:get_base()) end
		end

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
		while #villages < math.ceil(num_villages * tclass.village_density_factor) do
			local pos = u + random_position(ran(v), map_size)
			if not village_block:contains(pos) then
				local vill = ""
				if map:contains(pos) then vill = map[pos]:get_village(ran(v)) end
				villages[pos] = vill
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

