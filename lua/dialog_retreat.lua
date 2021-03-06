<<
	local unit_descriptor_header = T.row {
		column { T.spacer { linked_group = "but" } },
		column { T.spacer { linked_group = "img" } },
		column { T.label  { linked_group = "typ", id = "header_type",  label = _"Type"} },
		column { T.label  { linked_group = "nam", id = "header_name",  label = _"Name" } },
		column { T.label  { linked_group = "lvl", id = "header_level", label = _"Level" } },
		column { T.label  { linked_group = "cst", id = "header_cost", label = _"Cost" } },
		column { T.label  { linked_group = "exp", id = "header_exp",   label = _"XP" } }
	}

	local unit_descriptor = T.row { T.column {
		T.toggle_panel
		{
			id = "unit_descriptor",
			T.grid { T.row {
				column { T.toggle_button { linked_group = "but", id = "toggle" } },
				column { T.image { linked_group = "img", id = "icon" } },
				column { T.label { linked_group = "typ", id = "type" } },
				column { T.label { linked_group = "nam", id = "name" } },
				column { T.label { linked_group = "lvl", id = "level" } },
				column { T.label { linked_group = "cst", id = "cost" } },
				column { T.label { linked_group = "exp", id = "exp" } }
			} }
		}
	} }

	local function populate_unit_descriptor(list, index, unit)
		wesnoth.set_dialog_value(false, list, index, "toggle")
		wesnoth.set_dialog_value(unit.__cfg.image.."~TC("..unit.side..",magenta)", list, index, "icon")
		wesnoth.set_dialog_value(unit.type,  list, index, "type")
		wesnoth.set_dialog_value(unit.name,  list, index, "name")
		wesnoth.set_dialog_value(unit.__cfg.level, list, index, "level")
		wesnoth.set_dialog_value(unit.__cfg.cost, list, index, "cost")
		wesnoth.set_dialog_value(unit.experience .. "/" .. unit.max_experience,
			list, index, "exp")
	end

	local retreat_dialog =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.linked_group { id = "but", fixed_width = true },
		T.linked_group { id = "img", fixed_width = true },
		T.linked_group { id = "typ", fixed_width = true },
		T.linked_group { id = "nam", fixed_width = true },
		T.linked_group { id = "lvl", fixed_width = true },
		T.linked_group { id = "cst", fixed_width = true },
		T.linked_group { id = "exp", fixed_width = true },

		T.grid
		{
			row { T.column { horizontal_grow = true, combat_info } },

			row { T.column { horizontal_grow = true, T.label
			{
				definition = "title",
				label = G"Which units shall cover your retreat?"
			} } },

			row { T.column { horizontal_grow = true, T.grid { row { T.column { horizontal_grow = true, T.listbox
			{
				id = "units",
				T.header { unit_descriptor_header },
				T.list_definition { unit_descriptor }
			} } } } } },

			row { T.column { horizontal_grow = true, T.grid { row
			{
				column { grow_factor = 1, T.spacer { horizontal_grow = true } },
				column { horizontal_alignment = "right", T.button { id = "ok", return_value = -1, label = _"OK" } },
				column { horizontal_alignment = "right", T.button { id = "cancel", return_value = -2, label = _"Cancel" } }
			} } } }
		}
	}

	Company._mt.functions =
	{
		hp = function(self)
			local hu = self.hitpoints - self.unit_damage
			if self.bl_damage == 0 then return tostring(hu)
			else return hu - self.bl_damage .. " - " .. hu - math.ceil(self.bl_damage/2)
			end
		end,

		unit_damage = function(self)
			local ret = rawget(self, "unit_damage")
			if ret == nil then return 0 else return ret end
		end,

		bl_damage = function(self)
			local ret = rawget(self, "bl_damage")
			if ret == nil then return 0 else return ret end
		end,

		bl = function(self)
			local bl_q = self.bl_quenching
			if bl_q == nil then return self.bloodlust
			else return math.max(self.bloodlust - bl_q, 0)
			end
		end,

		bl_quenching = function(self)
			local ret = rawget(self, "bl_quenching")
			if ret == nil then return 0 else return ret end
		end,

		xp = function(self)
			local xpg = self.xp_gain
			if xpg == nil then return self.experience
			else return self.experience + xpg
			end
		end,

		xp_gain = function(self)
			local ret = rawget(self, "xp_gain")
			if ret == nil then return 0 else return ret end
		end
	}

	function Company._mt.__index(self, key)
		local fun = Company._mt.functions[key]
		if fun ~= nil then return fun(self)
		else return nil
		end
	end

	local function death_xp(level)
		if level == 0 then return 4 end
		return 8 * level
	end

	local att, def = nil
	local winner, loser = nil
	local side = nil
	local units = nil
	local cover_retreat = {}

	local function update_combat_info()
		wesnoth.set_dialog_value(att.hp.." / "..att.max_hitpoints, "attacker_health")
		wesnoth.set_dialog_value(def.hp.." / "..def.max_hitpoints, "defender_health")
		wesnoth.set_dialog_value(att.xp.." / "..att.max_experience, "attacker_xp")
		wesnoth.set_dialog_value(def.xp.." / "..def.max_experience, "defender_xp")
		wesnoth.set_dialog_value(att.bl, "attacker_bloodlust")
		wesnoth.set_dialog_value(def.bl, "defender_bloodlust")
	end

	local function update_cover(index)
		cover_retreat[index] = wesnoth.get_dialog_value("units", index, "toggle")
		local cost = units[index].__cfg.cost
		local uxp = units[index].experience
		local bl_quenching = cost + 3*uxp
		if cover_retreat[index] then
			loser.unit_damage = loser.unit_damage + math.floor(cost/3)
			winner.bl_quenching = winner.bl_quenching + bl_quenching
			winner.xp_gain = winner.xp_gain + death_xp(units[index].__cfg.level)
		else
			loser.unit_damage = loser.unit_damage - math.floor(cost/3)
			winner.bl_quenching = winner.bl_quenching - bl_quenching
			winner.xp_gain = winner.xp_gain - death_xp(units[index].__cfg.level)
		end
		loser.bl_damage = winner.bl
		update_combat_info()
	end

	function show_retreat_dialog()
		local function preshow()
			att = wesnoth.get_variable("GN_ATTACKING_COMPANY")
			att = Company.new(att)
			def = wesnoth.get_variable("GN_DEFENDING_COMPANY")
			def = Company.new(def)

			wesnoth.set_dialog_value(att.name, "attacker")
			wesnoth.set_dialog_value(def.name, "defender")

			side = wesnoth.get_variable("side_number")

			winner, loser = att, def
			if def.side ~= side then winner, loser = def, att end

			loser.bl_damage = winner.bloodlust
			local total_loot = wesnoth.get_variable("GN_TOTAL_LOOT")
			if total_loot == nil then total_loot = 0 end
			winner.unit_damage = -total_loot

			units = { indices = {}, wunits = wesnoth.get_units({side = side, canrecruit = false}) }
			for index, unit in pairs(units.wunits) do
				if unit.moves == unit.max_moves then
					units.indices[#units.indices + 1] = index
				end
			end
			setmetatable(units, {
				__index = function(self, key) return self.wunits[self.indices[key]] end,
				__call = function(self) local i = 0 return function() i = i + 1 if i > #self.indices then return nil else return i, self.wunits[self.indices[i]] end end end })
			cover_retreat = {}
			for i, unit in units() do
				populate_unit_descriptor("units", i, unit)
				wesnoth.set_dialog_callback(function() update_cover(i) end, "units", i, "toggle")
			end

			update_combat_info()
		end

		local res = wesnoth.synchronize_choice( function()
			local user_choice = wesnoth.show_dialog(retreat_dialog, preshow)
			local ret_table = {}
			if user_choice == -1 then
				for i, cover in pairs(cover_retreat) do
					if cover then
						ret_table[#ret_table + 1] = { "id", { id = units[i].id } }
					end
				end
			end
			ret_table.user_choice = user_choice
			return ret_table
		end)

		if res.user_choice == -1 then
			wesnoth.set_variable("GN_RETREAT_DECISION", true)
			wesnoth.set_variable("GN_COVERING_UNIT")
			for i, id in ipairs(res) do
				wesnoth.set_variable(string.format("GN_COVERING_UNIT[%d].id", i-1), id[2].id)
			end
		else
			wesnoth.set_variable("GN_RETREAT_DECISION", false)
		end
	end
>>
