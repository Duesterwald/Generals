<<
	local a = ...
	local helper = wesnoth.require("lua/helper.lua")
	local terrain = {wesnoth.get_terrain(a.x1, a.y2), wesnoth.get_terrain(a.x2, a.y2)}
	local map_size = wesnoth.get_variable("GN_LOCAL_MAP_SIZE")

	function round(x)
		return math.floor(x+0.5)
	end

	HexVec = {}
	HexVec._mt = {}

	function HexVec.new(x,y)
		local vec = {}
		if type(x) == "table" then
			if type(x[1]) == "number" and type(x[2]) == "number" then
				vec = { x[1], x[2] }
			elseif type(x.x) == "number" and type(x.y) == "number" then
				vec = { x.x, x.y - math.ceil(x.x/2) }
			end
		elseif type(x) == "number" and type(y) == "number" then
			vec = { x, y - math.ceil(x/2) }
		end
		if vec == {} then error("No valid arguments for HexVec constructor!") end
		setmetatable(vec, HexVec._mt)
		return vec
	end

	function HexVec._mt.__add(a,b)
		if getmetatable(b) ~= HexVec._mt then
			error("Trying to add a non-HexVec on the right hand side.")
		end
		local res = HexVec.new(a)
		res[1], res[2] = res[1] + b[1], res[2] + b[2]
		return res
	end

	function HexVec._mt.__unm(a)
		return HexVec.new({-a[1], -a[2]})
	end

	function HexVec._mt.__sub(a,b)
		return a + (-b)
	end

	function HexVec._mt.__mul(a,s)
		if type(s) ~= "number" then error("Tried to multiply HexVec with non-scalar") end
		return HexVec.new({a[1]*s, a[2]*s})
	end

	function HexVec._mt.__div(a,s)
		if type(s) ~= "number" then error("Tried to divide HexVec by non-scalar") end
		return HexVec.new({a[1]/s, a[2]/s})
	end

	function HexVec._mt.__eq(u, v)
		return u.x == v.x and u.y == v.y
	end

	function HexVec._mt.__tostring(u)
		return "(" .. u.x .. ", " .. u.y .. ")"
	end

	function HexVec._mt.__index(vec, index)
		if index == "distance" or index == "length" then
			if vec[1] * vec[2] > 0 then return math.abs(vec[1] + vec[2])
			else return math.max(math.abs(vec[1]), math.abs(vec[2]))
			end

		elseif index == "x" then return vec[1]
		elseif index == "y" then return vec[2] + math.ceil(vec[1]/2)
		end
	end

	HexVecSet = {}
	HexVecSet._mt = {}

	function HexVecSet.new()
		local s = {}
		setmetatable(s, HexVecSet._mt)
		return s
	end

	function HexVecSet._vec2ind(u)
		return 100000 * u[1] + u[2]
	end

	function HexVecSet._mt.__index(s, u)
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Error: tried to obtain value of non-HexVec key" .. u)
			return nil
		end
		local entry = rawget(s, HexVecSet._vec2ind(u))
		if entry == nil then return nil else return entry[2] end
	end

	function HexVecSet._mt.__newindex(s, u, v)
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Error: tried to set value with non-HexVec key" .. u)
			return nil
		end
		rawset(s, HexVecSet._vec2ind(u), {u, v})
	end

	function HexVecSet._mt.__call(s)
		local val, current_index = nil
		return function()
			current_index, val = next(s, current_index)
			if val == nil then return nil else return val[1], val[2] end
		end
	end

	function HexVecSet._mt.__len(s)
		local l = 0
		for i in s() do l = l + 1 end
		return l
	end

	Map = {}
	Map._mt = {}

	function Map.new(map_dimension)
		local map = {}
		for i = 0, map_dimension.x + 1 do
			map[i] = {}
		end
		map._dimension_x = map_dimension.x + 1
		map._dimension_y = map_dimension.y + 1
		setmetatable(map, Map._mt)
		return map
	end

	function Map._mt.__newindex(m, u, t)
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Map-Error: tried to set value with non-HexVec key" .. u)
			return nil
		end
		if u.x < 0 or u.x > m.x or u.y < 0 or u.y > m.y then
			return nil
		end
		rawget(m, u.x)[u.y] = t
	end

	function Map._mt.__index(m, u)
		if u == "x" then return rawget(m, "_dimension_x")
		elseif u == "y" then return rawget(m, "_dimension_y")
		elseif type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Map-Error: tried to get value with non-HexVec key" .. u)
			return nil
		end
		if u.x < 0 or u.x > m.x or u.y < 0 or u.y > m.y then
			return nil
		end
		return rawget(m, u.x)[u.y]
	end

	function Map._mt.__call(m, x, y, value)
		if x < 0 or x > m.x or y < 0 or y > m.y then
			return nil
		end
		if value ~= nil then rawget(m, x)[y] = value end
		return rawget(m, x)[y]
	end

	function Map._mt.__tostring(m)
		local map_string = "border_size=1\nusage=map\n\n"
		for y = 0, m.y do
			for x = 0, m.x - 1 do
				map_string = map_string .. m(x, y) .. ','
			end
			map_string = map_string .. m(m.x, y) .. '\n'
		end
		return map_string
	end

	Terrain = {}
	Terrain._mt = {}
	Terrain.func = {}

	Terrain.class =
	{
		W = { village = {"^Vm"}, keep = {"Khw"}, castle = {"Chw"} },
		G = { village = {"^Ve", "^Vh", "^Vhr", "^Vwm", "^Vht", "^Vc", "^Vl" },
			keep = {"Ke", "Kh", "Kv", "Khr"},  castle = {"Ce", "Ch", "Cv", "Chr"} },
		A = { village = {"^Voa", "^Vea", "^Vha", "^Vca", "^Vla", "^Vaa"},
			keep = {"Kea", "Koa", "Kha"}, castle = {"Cea", "Coa", "Cha"} },
		D = { village = {"^Vda", "^Vdt"}, keep = {"Kd", "Kdr"}, castle = {"Cd", "Cdr"} },
		S = { village = {"^Vhs"}, keep = {"Khs"}, castle = {"Chs"} },
		M = { village = {"^Vo", "^Vhh", "^Vd"}, keep = {"Ko", "Kud"}
	}

	function Terrain.new(terrain)
		local t = { _code = terrain }

		function t.base(t, r)
			hat = strfind(t._code, "^")
			if hat ~= nil then return strsub(t._code, 1, hat - 1) end
			return t._code
		end

		function t.overlay(t, r)
			hat = strfind(t._code, "^")
			if hat ~= nil then return strsub(t._code, hat) end
			return ""
		end

		function t.code(t, r)
			return t:base(r) .. t:overlay(r)
		end

		return t
	end

	adjacent_offset =
	{
		HexVec.new({ 0,-1}),
		HexVec.new({ 1,-1}),
		HexVec.new({ 1, 0}),
		HexVec.new({ 0, 1}),
		HexVec.new({-1, 1}),
		HexVec.new({-1, 0})
	}

	function dir(u)
		local l = u.length
		for d = 1, 6 do
			if adjacent_offset[d]*l == u then return d end
		end
		return nil
	end

	--! Returns an iterator over adjacent locations that can be used in a for-in loop.
	local function adjacent_tiles(v)
		local i = 1
		return function()
			while i <= 6 do
				local u = v + adjacent_offset[i]
				i = i + 1
				return u
			end
			return nil
		end
	end

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
	local seed = map_dim[1] * 8363 * map_dim[2] + map_dim[2] * 91
	local seed_store = HexVecSet.new()

	local function ran(v)
		if seed_store[v] == nil then
			seed_store[v] = seed * (v[1] * 7369 + v[2])
		end
		seed_store[v] = (seed_store[v] * 1103515245 + 12345) % 2147483648
		return seed_store[v]/2147483648
	end

	local function feature(global_position, local_position)
		palette = {}
		for tile in adjacent_tiles(global_position) do
			-- analyse palette
			
		local f = HexVecSet.new()
		f[start] = terrain
		local last_dir = nil
		while #f < length do
			local c,C = {},0
			for i = 1,6 do
				c[i] = correlation(i, last_dir)
				print("correlation "..i, c[i])
				C = C + c[i]
			end
			local r = ran(start) * C
			print("Random", r)
			for i = 1,6 do
				r = r - c[i]
				if r <= 0 then
					last_dir = i
					break
				end
			end
			print(last_dir)
			repeat
				start = start + adjacent_offset[last_dir]
			until f[start] == nil
			f[start] = terrain
		end
		return f
	end

	local function sawtooth(maximum, deviation, direction)
			if maximum == nil or deviation == nil then return 1 end
			if deviation < 0 then
				direction = (direction + 3) % 6
				deviation = -deviation
			end
			local x = math.abs(direction - maximum)
			return math.max(deviation - x, 0, x + deviation - 6)
	end

	local function correlation(bias, bias_deviation, correlation_strength)
		return function(direction, last_dir)
			if ( direction - last_dir + 6 ) % 6 == 3 then return 0 end
			return sawtooth(bias, bias_deviation, direction) * sawtooth(last_dir, correlation_strength, direction)
		end
	end

	local keep = { map_center - atkdir * map_size, map_center + atkdir * map_size }
	local keep_conn = {}
	for i = 1,6 do keep_conn[i] = adjacent_offset[i]*(map_size*2) end

	local adjacent_keep = HexVecSet.new()
	for i = 1,2 do
		for j = 1,6 do
			local u = keep[i] + keep_conn[j]
			local v = location[i] + adjacent_offset[j]
			adjacent_keep[u] = Terrain.new(wesnoth.get_terrain(v.x, v.y))
		end
	end

	local map = Map.new(map_dim)
	for x = 0, map.x do
		for y = 0, map.y do
			local min_dis = 4 * map_size
			for u, terrain in adjacent_keep() do
				local dis = ( HexVec.new(x, y) - u ).length
				if dis < min_dis then
					map(x, y, terrain.code())
					min_dis = dis
				elseif dis == min_dis then map(x, y, "Xv")
				end
			end
		end
	end

	for k in adjacent_keep() do
		map[k] = "Ke"
		for u in adjacent_tiles(k) do
			map[u] = "Ce"
		end
	end

	local rd = feature(keep[1] + atkdir*2, 2*map_size + 1, correlation(dir(atkdir), nil, -7, ld), "Rd")
	for u, t in rd() do map[u] = t end

	wesnoth.set_variable("local_map", tostring(map))
	wesnoth.set_variable("GN_ATTACKER_X", keep[1].x)
	wesnoth.set_variable("GN_ATTACKER_Y", keep[1].y)
	wesnoth.set_variable("GN_DEFENDER_X", keep[2].x)
	wesnoth.set_variable("GN_DEFENDER_Y", keep[2].y)
>>

