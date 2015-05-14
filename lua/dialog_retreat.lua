<<
	local unit_descriptor_header = T.row {
		column { T.spacer { linked_group = "but" } },
		column { T.spacer { linked_group = "img" } },
		column { T.label  { linked_group = "typ", id = "header_type",  label = _"Type"} },
		column { T.label  { linked_group = "nam", id = "header_name",  label = _"Name" } },
		column { T.label  { linked_group = "lvl", id = "header_level", label = _"Level" } },
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
				column { T.label { linked_group = "exp", id = "exp" } }
			} }
		}
	} }

	local function populate_unit_descriptor(list, index, wesnoth_variable)
		wesnoth.set_dialog_value(false, list, index, "toggle")
		wesnoth.set_dialog_value(wesnoth_variable.__cfg.image, list, index, "icon")
		wesnoth.set_dialog_value(wesnoth_variable.type,  list, index, "type")
		wesnoth.set_dialog_value(wesnoth_variable.name,  list, index, "name")
		wesnoth.set_dialog_value(wesnoth_variable.__cfg.level, list, index, "level")
		wesnoth.set_dialog_value(wesnoth_variable.experience .. "/" .. wesnoth_variable.max_experience,
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
		T.linked_group { id = "exp", fixed_width = true },

		T.grid
		{
			row { T.column { horizontal_grow = true, combat_info } },

			row { T.column { horizontal_grow = true, T.label
			{
				definition = "title",
				label = _G"Which units shall cover your retreat?"
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

	local att, def = nil
	local side = nil
	local units = nil
	local cover_retreat = {}

	local function update_cover(index)
		cover_retreat[index] = wesnoth.get_dialog_value("units", index, "toggle")
		local bl_quenching = units[index].__cfg.cost + units[index].experience
		local winner, loser = att, def
		if def.side ~= side then winner, loser = def, att end
		if cover_retreat[index] then winner.bloodlust = winner.bloodlust - bl_quenching
		else winner.bloodlust = winner.bloodlust + bl_quenching
		end
		wesnoth.set_dialog_value(att.hp.." / "..att.max_hitpoints, "attacker_health")
		wesnoth.set_dialog_value(def.hp.." / "..def.max_hitpoints, "defender_health")
		wesnoth.set_dialog_value(att.experience.." / "..att.max_experience, "attacker_xp")
		wesnoth.set_dialog_value(def.experience.." / "..def.max_experience, "defender_xp")
		wesnoth.set_dialog_value(att.bloodlust, "attacker_bloodlust")
		wesnoth.set_dialog_value(def.bloodlust, "defender_bloodlust")
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
			units = wesnoth.get_units({side = side, canrecruit = false})
			for i, unit in pairs(units) do
				populate_unit_descriptor("units", i, unit)
				wesnoth.set_dialog_callback(function() update_cover(i) end, "units", i, "toggle")
			end

			if att.side == side then att.min_damage = def.bloodlust
			else def.min_damage = att.bloodlust
			end

			update_combat_info(att, def)
		end

		wesnoth.show_dialog(retreat_dialog, preshow)
	end
>>
