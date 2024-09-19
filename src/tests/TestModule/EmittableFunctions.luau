local EmittableFunctions = {
	Server = {
		["Events"] = {
            ["TestEvent"] = function()
                print("This will not return anything but run something on the Server!")
            end	
		},
		["Callbacks"] = {
			["TestCallback"] = function()
                print("This WILL return something AND run something on the Server.")
            end
		},
	},
	Client = {
		["Events"] = {
            ["TestEvent"] = function()
                print("This will not return anything but run something on the client!")
            end
		},
		["Callbacks"] = {
			["TestCallback"] = function()
                print("This WILL return something AND run something on the client.")
            end
		},
	},
	["Name"] = script.Parent.Name 
}

return EmittableFunctions
