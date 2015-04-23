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
			hill = {},
			mountain = {},
			forest = {"^Ewl", "^Ewf"}
		},
		-- Shallow Water
		W =
		{
			pressure = 10,
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
			hill = {},
			mountain = {},
			forest = {"^Ewl", "^Ewf"}
		},
		-- Grass
		G =
		{
			pressure = 13,
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
			flat = {"Gg", "Gs", "Gd", "Gll", "Ww", "Rr", "Re"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fet", "^Fp", "^Fds", "^Fdf", "^Fms", "^Fmf"}
		},
		-- Dirt
		R =
		{
			pressure = 5,
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
			flat = {"Gg", "Gs", "Rb", "Re", "Rd", "Rr", "Rp", "Sm", "Gll"},
			hill = {"Hhd"},
			mountain = {"Md"},
			forest = {"^Fet", "^Fp", "^Fds", "^Fdf", "^Fms", "^Fmf"}
		},
		-- Frozen
		A =
		{
			pressure = 15,
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
			flat = {"Ww", "Gll", "Rr", "Ai", "Aa"},
			hill = {"Ha"},
			mountain = {"Ms"},
			forest = {"^Fpa", "^Fda", "^Fma"}
		},
		-- Desert
		D =
		{
			pressure = 15,
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
			flat = {"Rd", "Rr", "Dd", "Ds"},
			hill = {"Hd"},
			mountain = {"Md"},
			forest = {"^Ftd", "^Do"}
		},
		-- Swamp
		S =
		{
			pressure = 14,
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
			flat = {"Ss", "Sm", "Gll", "Rb", "Rp"},
			hill = {"Hh"},
			mountain = {"Mm"},
			forest = {"^Ft", "^Ftr"}
		},
		-- Hill
		H =
		{
			pressure = 15,
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
			flat = {"Ww", "Gg", "Gs", "Gll", "Re", "Rp"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fdw", "^Fmw"}
		},
		-- Mountain
		M =
		{
			pressure = 20,
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
			flat = {"Re", "Rr", "Rp"},
			hill = {"Hh", "Hhd"},
			mountain = {"Mm", "Md"},
			forest = {"^Fdw", "^Fmw"}
		},
		-- Underground
		U =
		{
			pressure = 9,
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
			flat = {"Uu", "Uue", "Urb", "Ur", "Uh"},
			hill = {},
			mountain = {},
			forest = {"^Uf"}
		},
		-- Unwalkable
		Q =
		{
			pressure = 5,
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
			hill = {},
			mountain = {},
			forest = {}
		},
		-- Impassable
		X =
		{
			pressure = 5,
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

		get_forest = function (self, r)
			local f = self:get_class()
			local i = nil
			i,r = ran_int(r, #f.forest)
			return f.forest[i], r
		end,

		get_forest_density = function (self)
			if #self._overlay < 2 or string.sub(self._overlay, 1, 2) ~= "^F" then
				return self:get_class().forest_density
			else
				return self:get_class().forest_density * 50
			end
		end
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
				map[i][j] = Terrain.new("Gg")
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

	print("Terrain.lua loaded.")
>>
