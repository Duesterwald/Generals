<<
	local _ = wesnoth.textdomain("wesnoth")
	local T = {}
	setmetatable(T, { __index = function (self, key) return function(val) return { key, val } end end })

	local dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid { T.row {
			T.column { T.grid {
				T.row { T.column { horizontal_grow = true, T.listbox { id = "the_list",
				T.list_definition { T.row { T.column { horizontal_grow = true,
				T.toggle_panel { T.grid { T.row {
					T.column { horizontal_alignment = "left", T.label { id = "the_label" } },
					T.column { T.image { id = "the_icon" } }
				} } }
			} } }
		} } },
		T.row { T.column { T.grid { T.row {
			T.column { T.button { id = "ok", label = _"OK" } },
			T.column { T.button { id = "cancel", label = _"Cancel" } }
		} } } }
	} },
	T.column { T.image { id = "the_image" } }
	  } }
	}

	local function preshow()
		local t = { "Ancient Lich", "Ancient Wose", "Elvish Avenger" }
		local function select()
			local i = wesnoth.get_dialog_value "the_list"
			local ut = wesnoth.unit_types[t[i]].__cfg
			wesnoth.set_dialog_value(string.gsub(ut.profile, "([^/]+)$", "transparent/%1"), "the_image")
		end
		wesnoth.set_dialog_callback(select, "the_list")
		for i,v in ipairs(t) do
			local ut = wesnoth.unit_types[v].__cfg
			wesnoth.set_dialog_value(ut.name, "the_list", i, "the_label")
			wesnoth.set_dialog_value(ut.image, "the_list", i, "the_icon")
		end
		wesnoth.set_dialog_value(2, "the_list")
		select()
	end

	local li = 0
	local function postshow()
		li = wesnoth.get_dialog_value "the_list"
	end

	local r = wesnoth.show_dialog(dialog, preshow, postshow)
	wesnoth.message(string.format("Button %d pressed. Item %d selected.", r, li))

	print("dialog.lua loaded")
>>
