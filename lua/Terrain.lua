<<
	Terrain = {}
	Terrain._mt = {}
	Terrain.func = {}

	function Terrain.base_remap(base_terrain)
		if     base_terrain == "Ce"
			or base_terrain == "Ke"
			or base_terrain == "Ket" then return "Re"
		elseif base_terrain == "Cea"
			or base_terrain == "Cha"
			or base_terrain == "Kea"
			or base_terrain == "Kha" then return "Aa"
		elseif base_terrain == "Co" then return "Hhd"
		elseif base_terrain == "Ko" then return "Md"
		elseif base_terrain == "Coa"
			or base_terrain == "Koa" then return "Ha"
		elseif base_terrain == "Ch" then return "Rr"
		elseif base_terrain == "Kh" then return "Rrc"
		elseif base_terrain == "Cv"
			or base_terrain == "Kv" then return "Gg"
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
	end

	function Terrain.class(terrain_key)
		-- Water
		if terrain_key == "W" then return
		{
			village = {"^Vm"},
			keep = {"Khw"},
			castle = {"Chw"},
			forest = {"^Ewl", "^Ewf"}
		}
		-- Grass/Flat
		elseif terrain_key == "G" or terrain_key == "R" then return
		{
			village = {"^Ve", "^Vh", "^Vhr", "^Vwm", "^Vht", "^Vc", "^Vl" },
			keep = {"Ke", "Kh", "Kv", "Khr"},
			castle = {"Ce", "Ch", "Cv", "Chr"},
			forest = {"^Fet", "^Fp", "^Fds", "^Fdf", "^Fms", "^Fmf"}
		}
		-- Frozen
		elseif terrain_key == "A" then return
		{
			village = {"^Voa", "^Vea", "^Vha", "^Vca", "^Vla", "^Vaa"},
			keep = {"Kea", "Koa", "Kha"},
			castle = {"Cea", "Coa", "Cha"},
			forest = {"^Fpa", "^Fda", "^Fma"}
		}
		-- Desert
		elseif terrain_key == "D" then return
		{
			village = {"^Vda", "^Vdt"},
			keep = {"Kd", "Kdr"},
			castle = {"Cd", "Cdr"},
			forest = {"^Ftd", "^Ftp"}
		}
		-- Swamp
		elseif terrain_key == "S" then return
		{
			village = {"^Vhs"},
			keep = {"Khs"},
			castle = {"Chs"},
			forest = {"^Ft", "^Ftr"}
		}
		elseif terrain_key == "H" or terrain_key == "M" then return
		-- Hill/Mountain
		{
			village = {"^Vo", "^Vhh", "^Vd"},
			keep = {"Ko"},
			castle = {"Co"},
			forest = {"^Fdw", "^Fmw"}
		}
		elseif terrain_key == "U" or terrain_key == "Q" then return
		-- Underground
		{
			village = {"^Vu", "Vud"},
			keep = {"Kud"},
			castle = {"Cud"},
			forest = {"^Uf"}
		}
		end
	end

	function Terrain.class_exception(base_terrain)
		if     base_terrain == "Hd" then return "D"
		elseif base_terrain == "Ha" then return "A"
		elseif base_terrain == "Ms" then return "A"
		elseif base_terrain == "Xu"
			or base_terrain == "Xuc"
			or base_terrain == "Xue"
			or base_terrain == "Xuce"
			or base_terrain == "Xos"
			or base_terrain == "Xol" then return "U"
		end
	end

	function Terrain.new(terrain)
		local t = { _code = terrain }
		local hat = string.find(terrain, "^", 1, true)
		if hat ~= nil then
			t._base = string.sub(terrain, 1, hat - 1)
			t._overlay = string.sub(terrain, hat)
		else
			t._base = terrain
			t._overlay = ""
		end

		print("terrain "..t._base..t._overlay)

		function t.base(self, r)
			if Terrain.base_remap(t._base) ~= nil then return Terrain.base_remap(t._base),r end
			return self._base, r
		end

		function t.overlay(self, r)
			return self._overlay, r
		end

		function t.class(self,r)
			local b = nil
			b,r = self:base(r)
			if Terrain.class_exception(b) ~= nil then
				return Terrain.class(Terrain.class_exception(b))
			end
			return Terrain.class(string.sub(b,1,1)), r
		end

		function t.village(self,r)
			local v, i = nil
			v,r = self:class(r)
			i,r = ran_int(r, #v.village)
			return v.village[i], r
		end

		function t.keep_and_castle(self,r)
			local v, i = nil
			v,r = self:class(r)
			i,r = ran_int(r, #v.keep)
			return v.keep[i], v.castle[i], r
		end

		function t.code(self, r)
			local b, o = nil
			b,r = self:base(r)
			o,r = self:overlay(r)
			return b..o, r
		end

		return t
	end

	print("Terrain.lua loaded, max_num_feature = "..max_num_feature)
>>
