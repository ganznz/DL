local FURNITURE_CATEGORIES = {"Energy", "Hunger", "Mood", "Decor"}

return function (registry)
    registry:RegisterType("furnitureCategory", registry.Cmdr.Util.MakeEnumType("furnitureCategory", FURNITURE_CATEGORIES))
end 