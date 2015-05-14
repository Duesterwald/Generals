<<
	combat_info = T.grid
	{
		row
		{
			column { T.spacer { horizontal_grow = true, grow_factor = 1 } },
			column { horizontal_alignment = "right", T.label { definition = "title", id = "attacker" } },
			column { T.label { definition = "title", label = _G"vs." } },
			column { T.label { definition = "title", id = "defender" } }
		},
		row
		{
			column { T.label { label = _G"Health" } },
			column { horizontal_alignment = "right", T.label { id = "attacker_health" } },
			column { T.spacer { horizontal_grow = true } },
			column { T.label { id = "defender_health" } }
		},
		row
		{
			column { T.label { label = _G"Experience" } },
			column { horizontal_alignment = "right", T.label { id = "attacker_xp" } },
			column { T.spacer { horizontal_grow = true } },
			column { T.label { id = "defender_xp" } }
		},
		row
		{
			column { T.label { label = _G"Bloodlust" } },
			column { horizontal_alignment = "right", T.label { id = "attacker_bloodlust" } },
			column { T.spacer { horizontal_grow = true } },
			column { T.label { id = "defender_bloodlust" } }
		},
	}

	local combat_info_dialog =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.grid
		{
			row { column { combat_info } },

			row { T.column { horizontal_grow = true, T.grid { row
			{
				column { T.button { id = "retreat", return_value = 1, label = _G"Retreat" } },
				column { T.spacer { horizontal_grow = true, grow_factor = 1 } },
				column { horizontal_alignment = "right", T.button { id = "ok", return_value = -1, label = _"OK" } }
			} } } }
		}
	}

	Company = {}
	Company._mt = {}

	function Company._mt.__index(self, key)
		if key == "hp" then
			local hp = self.hitpoints - self.unit_damage

			return tostring(hp - self.max_damage) .. " - " .. tostring(hp - self.min_damage)
		end

		return nil
	end

	function Company.new(index)
		local comp = wesnoth.get_variable("GN_COMPANY["..index.."].company")
		setmetatable(comp, Company._mt)
		comp.bloodlust = wesnoth.get_variable("GN_COMPANY["..index.."].bloodlust")
		comp.unit_damage = 0
		comp.bl_damage = 0
		return comp
	end

	function show_combat_info()
		local function preshow()
			local att = wesnoth.get_variable("GN_ATTACKING_COMPANY")
			att = Company.new(att)
			local def = wesnoth.get_variable("GN_DEFENDING_COMPANY")
			def = Company.new(def)

			wesnoth.set_dialog_value(att.name, "attacker")
			wesnoth.set_dialog_value(def.name, "defender")

			wesnoth.set_dialog_value(att.hp.." / "..att.max_hitpoints, "attacker_health")
			wesnoth.set_dialog_value(def.hp.." / "..def.max_hitpoints, "defender_health")

			wesnoth.set_dialog_value(att.experience.." / "..att.max_experience, "attacker_xp")
			wesnoth.set_dialog_value(def.experience.." / "..def.max_experience, "defender_xp")

			wesnoth.set_dialog_value(att.bloodlust, "attacker_bloodlust")
			wesnoth.set_dialog_value(def.bloodlust, "defender_bloodlust")
		end

		if wesnoth.show_dialog(combat_info_dialog, preshow) == 1 then
			show_retreat_dialog()
		end
	end
>>
