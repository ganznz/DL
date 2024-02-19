local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- furniture configs
local MaterialConfig = require(ReplicatedStorage.Configs.Materials.Materials)

return {
    Name = "giveMaterial";
    Aliases = { "gm" };
    Description = "Give player a specific material";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
        },
        function(context)
            local allMaterials = MaterialConfig.Config

            local materialNames = {}
            for materialName, _materialInfo in allMaterials do
                table.insert(materialNames, materialName)
            end

            return {
                Type = context.Cmdr.Util.MakeEnumType("material", materialNames),
                Name = "Material",
                Description = "The type of material to give to the player."
            }
        end,
        {
            Type = "number";
            Name = "Amount";
            Description = "The amount of selected material to give to the player";
        }
    }
}