local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- furniture configs
local EnergyFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("EnergyFurniture"))
local HungerFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("HungerFurniture"))
local MoodFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("MoodFurniture"))
local DecorFurnitureConfig = require(ReplicatedStorage.Configs.Furniture:WaitForChild("DecorFurniture"))

return {
    Name = "giveFurniture";
    Aliases = { "gf" };
    Description = "Give player a furniture item";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
        },
        {
            Type = "furnitureCategory";
            Name = "Furniture Category";
            Description = "Category of the item."
        },
        function(context)
            local selectedCategory = context:GetArgument(2):GetValue()
            local furnitureConfig

            if selectedCategory == "Energy" then
                furnitureConfig = EnergyFurnitureConfig.Config
            elseif selectedCategory == "Hunger" then
                furnitureConfig = HungerFurnitureConfig.Config
            elseif selectedCategory == "Mood" then
                furnitureConfig = MoodFurnitureConfig.Config
            elseif selectedCategory == "Decor" then
                furnitureConfig = DecorFurnitureConfig.Config
            else
                -- entered value is invalid
                return
            end

            local furnitureItems = {}
            for itemName, _itemInfo in furnitureConfig do
                table.insert(furnitureItems, itemName)
            end

            return {
                Type = context.Cmdr.Util.MakeEnumType("furnitureItem", furnitureItems),
                Name = "Furniture item",
                Description = "The furniture item to give the player."
            }
        end

    }
}