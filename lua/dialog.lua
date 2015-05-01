<<
	local _ = wesnoth.textdomain("wesnoth")
	local T = {}
	setmetatable(T, { __index = function (self, key) return function(val) return { key, val } end end })

	local unit_descriptor = T.row
	{
		T.column
		{
			border = "all",
			border_size = 5,
			horizontal_alignment = "left",
			T.image { id = "unit_descriptor_icon" }
		},
		T.column
		{
			border = "all",
			border_size = 5,
			horizontal_alignment = "left",
			T.label { id = "unit_descriptor_name" }
		}
	}

	local company_info_dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid
		{
			T.row { T.column { horizontal_grow = true,
				T.listbox { id = "the_list", T.list_definition { unit_descriptor } }
			} },
			T.row { T.column { T.grid { T.row {
				T.column { T.button { id = "ok", label = _"OK" } }
			} } } }
		}
	}

	function show_company(index)
		local function preshow()
			local img = wesnoth.get_variable("GN_COMPANY["..index.."].captain.image")
			local name = wesnoth.get_variable("GN_COMPANY["..index.."].captain.name")
			wesnoth.set_dialog_value(img, "the_list", 0, "unit_descriptor_icon")
			wesnoth.set_dialog_value(name, "the_list", 0, "unit_descriptor_name")
			wesnoth.set_dialog_value(0, "the_list")
		end

		local li = 0
		local function postshow()
			li = wesnoth.get_dialog_value "the_list"
		end

		local r = wesnoth.show_dialog(dialog, preshow, postshow)
		wesnoth.message(string.format("Button %d pressed. Item %d selected.", r, li))
	end

	print("dialog.lua loaded")
>>
