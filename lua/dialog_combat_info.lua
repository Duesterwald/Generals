<<
	local combat_info_dialog =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.linked_group { id = "des", fixed_width = true },
		T.linked_group { id = "lef", fixed_width = true },
		T.linked_group { id = "mid", fixed_width = true },
		T.linked_group { id = "rgt", fixed_width = true },

		T.grid
		{
			row
			{
				column { linked_group = "des", T.spacer { horizontal_grow = true, grow_factor = 1 } },
				column { linked_group = "lef", horizontal_alignment = "right", T.label { definition = "title", id = "attacker" } },
				column { linked_group = "mid", T.label { definition = "title", label = _G"vs." } },
				column { linked_group = "rgt", T.label { definition = "title", id = "defender" } }
			},
			row
			{
				column { linked_group = "des", T.label { label = _G"Health" } },
				column { linked_group = "lef", horizontal_alignment = "right", T.label { id = "attacker_health" } },
				column { linked_group = "mid", T.spacer { horizontal_grow = true } },
				column { linked_group = "rgt", T.label { id = "defender_health" } }
			},
			row
			{
				column { linked_group = "des", T.label { label = _G"Experience" } },
				column { linked_group = "lef", horizontal_alignment = "right", T.label { id = "attacker_xp" } },
				column { linked_group = "mid", T.spacer { horizontal_grow = true } },
				column { linked_group = "rgt", T.label { id = "defender_xp" } }
			},
			row
			{
				column { T.button { id = "retreat", return_value = 1, label = _G"Retreat" } },
				column { T.spacer { horizontal_grow = true, grow_factor = 1 } },
				column { T.spacer { horizontal_grow = true, grow_factor = 1 } },
				column { horizontal_alignment = "right", T.button { id = "ok", return_value = -1, label = _"OK" } }
			}
		}
	}

	function show_combat_info()
		local function preshow()
			local att = wesnoth.get_variable("GN_ATTACKING_COMPANY")
			att = wesnoth.get_variable("GN_COMPANY["..att.."].company")
			local def = wesnoth.get_variable("GN_DEFENDING_COMPANY")
			def = wesnoth.get_variable("GN_COMPANY["..def.."].company")

			wesnoth.set_dialog_value(att.name, "attacker")
			wesnoth.set_dialog_value(def.name, "defender")
			wesnoth.set_dialog_value(att.hitpoints, "attacker_health")
			wesnoth.set_dialog_value(def.hitpoints, "defender_health")
			wesnoth.set_dialog_value(att.experience, "attacker_xp")
			wesnoth.set_dialog_value(def.experience, "defender_xp")
		end

		if wesnoth.show_dialog(combat_info_dialog, preshow) == 1 then
			print("Retreat")
		end
	end
>>
