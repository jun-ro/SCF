local Defaults = {
	["Events"] = {

	},
	["Callbacks"] = {
		["GetEvents"] = function()
			return "Hello World"
		end,
	},
	["Name"] = "Default"
}

return Defaults
