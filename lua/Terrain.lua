<<
	Terrain = {}
	Terrain._mt = {}
	Terrain.func = {}

	function Terrain.base_remap(base_terrain)
		if     base_terrain == nil
			or base_terrain == ""    then return "Xv"

		elseif base_terrain == "Ce"
			or base_terrain == "Ke"
			or base_terrain == "Ket" then return "Re"

		elseif base_terrain == "Cea"
			or base_terrain == "Cha"
			or base_terrain == "Kea"
			or base_terrain == "Kha" then return "Aa"

		elseif base_terrain == "Co"  then return "Hhd"

		elseif base_terrain == "Ko"  then return "Md"

		elseif base_terrain == "Coa"
			or base_terrain == "Koa" then return "Ha"

		elseif base_terrain == "Ch"  then return "Rr"

		elseif base_terrain == "Kh"  then return "Rrc"

		elseif base_terrain == "Cv"
			or base_terrain == "Kv"  then return "Gg"

		elseif base_terrain == "Cud" then return "Ur"

		elseif base_terrain == "Kud" then return "Urb"

		elseif base_terrain == "Chr"
			or base_terrain == "Khr" then return "Rp"

		elseif base_terrain == "Chw" then return "Ww"

		elseif base_terrain == "Khw" then return "Wwf"

		elseif base_terrain == "Chs"
			or base_terrain == "Khs" then return "Ss"

		elseif base_terrain == "Cd"
			or base_terrain == "Cdr"
			or base_terrain == "Kd"
			or base_terrain == "Kdr" then return "Dd"

		end
		return base_terrain
	end

	Terrain._class =
	{
		-- Ocean
		O =
		{
			pressure = 10,
			road_windedness = 0.,
			village_density_factor = 0.2,
			castle_density = 0,
			flat_density = 0,
			flat_size = 0,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 0,
			forest_size = 0,
			village = {"^Vm"},
			keep = {"Khw"},
			castle = {"Chw"},
			flat = {},
			road = {},
			hill = {},
			mountain = {},
			forest = {"^Ewl", "^Ewf"}
		},
		-- Shallow Water
		W =
		{
			pressure = 10,
			road_windedness = 0.3,
			village_density_factor = 0.5,
			castle_density = 5,
			flat_density = 10,
			flat_size = .4,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 10,
			forest_size = .2,
			village = {"^Vm"},
			keep = {"Khw"},
			castle = {"Chw"},
			flat = {"Wwf", "Ds"},
			road = {"Wwf"},
			hill = {},
			mountain = {},
			forest = {"^Ewl", "^Ewf"}
		},
		-- Grass
		G =
		{
			pressure = 13,
			road_windedness = 0.2,
			village_density_factor = 1,
			castle_density = 10,
			flat_density = 10,
			flat_size = .7,
			mountain_density = 5,
			mountain_size = 1.2,
			forest_density = 10,
			forest_size = 1.,
			village = {"^Ve", "^Vh", "^Vhr", "^Vwm", "^Vht", "^Vc", "^Vl" },
			keep = {"Ke", "Kh", "Kv", "Khr"},
			castle = {"Ce", "Ch", "Cv", "Chr"},
			flat = {"Gg", "Gs", "Gd", "Gll", "Ww", "Re"},
			road = {"Re", "Rr", "Rp"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fp", "^Fds", "^Fdf", "^Fms", "^Fmf"}
		},
		-- Dirt
		R =
		{
			pressure = 5,
			road_windedness = 0.1,
			village_density_factor = 1,
			castle_density = 10,
			flat_density = 30,
			flat_size = 1.0,
			mountain_density = 3,
			mountain_size = 1.0,
			forest_density = 5,
			forest_size = .3,
			village = {"^Vh", "^Vhr", "^Vwm", "^Vht", "^Vc", "^Vl" },
			keep = {"Ke", "Kh", "Khr"},
			castle = {"Ce", "Ch", "Chr"},
			flat = {"Gg", "Gs",  "Sm", "Gll"},
			road = {"Re", "Rr", "Rp"},
			hill = {"Hhd"},
			mountain = {"Md"},
			forest = {"^Fp", "^Fdf", "^Fms", "^Fmf"}
		},
		-- Frozen
		A =
		{
			pressure = 15,
			road_windedness = 0.3,
			village_density_factor = 0.7,
			castle_density = 20,
			flat_density = 20,
			flat_size = 1.0,
			mountain_density = 5,
			mountain_size = 1.2,
			forest_density = 10,
			forest_size = .4,
			village = {"^Voa", "^Vea", "^Vha", "^Vca", "^Vla", "^Vaa"},
			keep = {"Kea", "Koa", "Kha"},
			castle = {"Cea", "Coa", "Cha"},
			flat = {"Ww", "Gll", "Ai", "Aa"},
			road = {"Re", "Rr"},
			hill = {"Ha"},
			mountain = {"Ms"},
			forest = {"^Fpa", "^Fda", "^Fma"}
		},
		-- Desert
		D =
		{
			pressure = 15,
			road_windedness = 0.2,
			village_density_factor = 0.7,
			castle_density = 5,
			flat_density = 10,
			flat_size = 1.0,
			mountain_density = 3,
			mountain_size = 1.0,
			forest_density = 3,
			forest_size = .4,
			village = {"^Vda", "^Vdt"},
			keep = {"Kd", "Kdr"},
			castle = {"Cd", "Cdr"},
			flat = {"Dd", "Ds"},
			road = {"Rd"},
			hill = {"Hd"},
			mountain = {"Md"},
			forest = {"^Ftd", "^Do"}
		},
		-- Swamp
		S =
		{
			pressure = 14,
			road_windedness = 0.5,
			village_density_factor = 0.7,
			castle_density = 10,
			flat_density = 5,
			flat_size = 1.0,
			mountain_density = 1,
			mountain_size = 1.0,
			forest_density = 9,
			forest_size = .5,
			village = {"^Vhs"},
			keep = {"Khs"},
			castle = {"Chs"},
			flat = {"Ss", "Sm", "Gll", "Rb"},
			road = {"Rp"},
			hill = {"Hh"},
			mountain = {"Mm"},
			forest = {"^Ft", "^Ftr"}
		},
		-- Hill
		H =
		{
			pressure = 15,
			road_windedness = 0.5,
			village_density_factor = 0.8,
			castle_density = 10,
			flat_density = 5,
			flat_size = 1.5,
			mountain_density = 20,
			mountain_size = .5,
			forest_density = 10,
			forest_size = .5,
			village = {"^Vo", "^Vhh", "^Vd"},
			keep = {"Ko"},
			castle = {"Co"},
			flat = {"Ww", "Gg", "Gs", "Gll"},
			road = {"Re", "Rp"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fdw", "^Fmw"}
		},
		-- Mountain
		M =
		{
			pressure = 20,
			road_windedness = 0.6,
			village_density_factor = 0.6,
			castle_density = 5,
			flat_density = 2,
			flat_size = 1.0,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 3,
			forest_size = .3,
			village = {"^Vo", "^Vhh", "^Vd"},
			keep = {"Ko"},
			castle = {"Co"},
			flat = {"Gg", "Gs", "Ww"},
			road = {"Re", "Rp"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fdw", "^Fmw"}
		},
		-- Underground
		U =
		{
			pressure = 9,
			road_windedness = 0.5,
			village_density_factor = 0.6,
			castle_density = 10,
			flat_density = 10,
			flat_size = 1.0,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 15,
			forest_size = .1,
			village = {"^Vu", "^Vud"},
			keep = {"Kud"},
			castle = {"Cud"},
			flat = {"Uu", "Uue", "Urb", "Uh"},
			road = {"Ur"},
			hill = {},
			mountain = {},
			forest = {"^Uf"}
		},
		-- Unwalkable
		Q =
		{
			pressure = 5,
			road_windedness = 0.,
			village_density_factor = 0,
			castle_density = 0,
			flat_density = 10,
			flat_size = 1.0,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 0,
			forest_size = 0,
			village = {},
			keep = {"Kud"},
			castle = {"Cud"},
			flat = {"Uu", "Uue", "Urb", "Ur", "Uh"},
			road = {},
			hill = {},
			mountain = {},
			forest = {}
		},
		-- Impassable
		X =
		{
			pressure = 5,
			road_windedness = 0.,
			village_density_factor = 0,
			castle_density = 0,
			flat_density = 0,
			flat_size = 0,
			mountain_density = 0,
			mountain_size = 0,
			forest_density = 0,
			forest_size = 0,
			village = {},
			keep = {"Kud"},
			castle = {"Cud"},
			flat = {},
			road = {},
			hill = {},
			mountain = {},
			forest = {}
		}
	}

	function Terrain.class(terrain_key)
		local t = Terrain.new(terrain_key)
		return Terrain._unsafe_class(t:base())
	end

	function Terrain._unsafe_class(terrain_key)
		if     terrain_key == "Hd" then terrain_key = "D"

		elseif terrain_key == "Ha" then terrain_key = "A"

		elseif terrain_key == "Ms" then terrain_key = "A"

		elseif terrain_key == "Wog"
			or terrain_key == "Wo"
			or terrain_key == "Wot" then terrain_key = "O"

		else terrain_key = string.sub(terrain_key, 1, 1)
		end
		return Terrain._class[terrain_key]
	end

	Terrain._mt = {}

	function Terrain.new(terrain)
		local t = {}
		setmetatable(t, Terrain._mt)
		t:set_code(terrain)
		return t
	end

	function Terrain._mt.__index(self, key)
		return Terrain._functions[key]
	end

	Terrain._functions =
	{
		set_code = function (self, code)
			local hat = string.find(code, "^", 1, true)
			if hat ~= nil then
				self._base = string.sub(code, 1, hat - 1)
				self._overlay = string.sub(code, hat)
			else
				self._base = code
				self._overlay = ""
			end
			if self._overlay == nil then error("overlay is nil for code "..code) end
		end,

		get_code = function (self)
			return self._base..self._overlay
		end,

		get_base = function (self)
			return Terrain.base_remap(self._base)
		end,

		set_base = function (self, base)
			self._base = base
			self._code = self._base..self._overlay
		end,

		get_overlay = function (self)
			return self._overlay
		end,

		set_overlay = function(self, overlay)
			self._base = Terrain.base_remap(self._base)
			self._overlay = overlay
			if self._overlay == nil then error("overlay is nil for base "..self._base) end
		end,

		get_class = function (self)
			local b = nil
			b = self:get_base()
			return Terrain._unsafe_class(b)
		end,

		get_village = function (self,r)
			if self:is_town() then return self._overlay end
			local v = self:get_class()
			local i = nil
			i,r = ran_int(r, #v.village)
			return v.village[i], r
		end,

		get_keep_and_castle = function (self,r)
			key = string.sub(self._base, 1, 1)
			if key == "K" or key == "C" then
				if self._base == "Ket" then return "Ket", "Ce", r
				else return "K"..string.sub(self._base, 2), "C"..string.sub(self._base, 2), r end
			end
			local v, i = nil
			v = self:get_class()
			i,r = ran_int(r, #v.keep)
			return v.keep[i], v.castle[i], r
		end,

		get_overlay_features = function(self, rand_gen, start)
			local ov = self._overlay
			if ov == nil or #ov < 2 then return { overlay={}, base={}, full={}} end

			local sub = string.sub(ov, 1, 2)

			if  sub == "^F" then return
			{
				overlay={feature(rand_gen, start, map_size * map_size / 2, correlation(nil, nil, -3), ov)},
				base={},
				full={}
			}

			elseif sub == "^V" then
				local village = HexVecSet.super_hex(start, 1 + map_size/4, ov)
				local keep, castle = self:get_keep_and_castle(rand_gen())
				local wall = village:border(Terrain.new(castle))
				village:thin(rand_gen, 0.3)
				wall:thin(rand_gen, 0.2)
				return { overlay={village}, base={}, full={wall} }

			elseif ov == "^Do" then
				local oasis = feature(rand_gen, start, 2 + map_size * map_size / 16, correlation(ran_element(rand_gen(), {0.5, 2.5, 4.5}), 3, -4),Terrain.new("Wot"))
				oasis = oasis:border(Terrain.new("Wwt"), true)
				oasis = oasis:border(Terrain.new("Ds^Ftd"), true)
				return { overlay={}, base={}, full={oasis, shore} }

			end
			return { overlay={}, base={}, full={}}
		end,

		get_forest = function (self, r)
			local f = self:get_class()
			local i = nil
			i,r = ran_int(r, #f.forest)
			return f.forest[i], r
		end,

		has_forest = function (self)
			if #self._overlay < 2 then return false end
			return Terrain._forest_definition[self._overlay] or string.sub(self._overlay, 1, 2) == "^F"
		end,

		is_town = function (self)
			if #self._overlay < 2 then return false end
			return string.sub(self._overlay, 1, 2) == "^V"
		end
	}

	Terrain._forest_definition =
	{
		["^Do"] = true,
		["^Ewl"] = true,
		["^Ewf"] = true,
		["^Fet"] = true,
		["^Fetd"] = true,
		["^Ft"] = true,
		["^Ftr"] = true,
		["^Ftd"] = true,
		["^Ftp"] = true,
		["^Fts"] = true,
		["^Fp"] = true,
		["^Fpa"] = true,
		["^Fds"] = true,
		["^Fdf"] = true,
		["^Fdw"] = true,
		["^Fda"] = true,
		["^Fms"] = true,
		["^Fmf"] = true,
		["^Fmw"] = true,
		["^Fma"] = true,
		["^Uf"] = true,
	}

	function Terrain._mt.__tostring(self)
		return self._base..self._overlay
	end

	Map = {}
	Map._mt = {}

	function Map.new(map_dimension)
		local map = {}
		for i = 0, map_dimension.x + 1 do
			map[i] = {}
			for j = 0, map_dimension.y + 1 do
				map[i][j] = Terrain.new("Xv")
			end
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
		if not m:contains(u) then
			return nil
		end
		print("Error: Tried to set map directly.")
	end

	function Map._mt.__index(m, u)
		if u == "x" then return rawget(m, "_dimension_x")
		elseif u == "y" then return rawget(m, "_dimension_y")
		elseif Map._functions[u] ~= nil then return Map._functions[u]
		elseif type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Map-Error: tried to get value with non-HexVec key" .. u)
			return nil
		end
		if not m:contains(u) then return nil end
		return rawget(m, u.x)[u.y]
	end

	Map._functions =
	{
		contains = function(self, u)
			return not (u.x < 0 or u.x > self.x or u.y < 0 or u.y > self.y)
		end,

		set_code = function(self, position, code)
			if self:contains(position) then
				self[position]:set_code(code)
			end
		end,

		set_base = function(self, position, base)
			if self:contains(position) then
				self[position]:set_base(base)
			end
		end,

		set_overlay = function(self, position, overlay)
			if self:contains(position) then
				self[position]:set_overlay(overlay)
			end
		end
	}

	function Map._mt.__call(m, x, y)
		if x < 0 or x > m.x or y < 0 or y > m.y then
			return nil
		end
		return rawget(m, x)[y]
	end

	function Map._mt.__tostring(m)
		local map_string = "border_size=1.\nusage=map\n\n"
		for y = 0, m.y do
			for x = 0, m.x - 1 do
				map_string = map_string .. tostring(m(x, y)) .. ','
			end
			map_string = map_string .. tostring(m(m.x, y)) .. '\n'
		end
		return map_string
	end

	function feature(rand_gen, start, length, correlation, terrain)
		local f = HexVecSet.new()
		f[start] = terrain
		local last_dir = 0
		while #f < length do
			last_dir = weighted_key(rand_gen(), correlation[last_dir])
			repeat
				start = start + adjacent_offset[last_dir]
			until f[start] == nil
			f[start] = terrain
		end
		return f
	end

	function road(rand_gen, start, diff, deviations, terrain)
		if diff.length < deviations then error("road(): deviations must be less than diff.length!") end
		local res = HexVecSet.new()
		res[start] = terrain
		local start_backup = start
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

		local corr = correlation(nil, nil, 2)
		local w = {}
		
		local next_dir = weighted_key(rand_gen(), dirs)
		while next_dir ~= nil do
			start = start + adjacent_offset[next_dir]
			res[start] = terrain
			dirs[next_dir] = dirs[next_dir] - 1
			for i = 1, 6 do w[i] = corr[next_dir][i] * math.sqrt(dirs[i]) end
			next_dir = weighted_key(rand_gen(), w)
		end

		if diff ~= start - start_backup then error("Road did not add up!") end
		return res
	end


	print("Terrain.lua loaded.")
>>
