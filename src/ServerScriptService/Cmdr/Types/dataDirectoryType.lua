local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlrDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local directories = {}
for directory, _value in PlrDataTemplate do
    table.insert(directories, directory)
end

return function (registry)
    registry:RegisterType("dataDirectory", registry.Cmdr.Util.MakeEnumType("dataDirectory", directories))
end