return {
    Name = "getPlayerData";
    Aliases = { "getData", "gpd" };
    Description = "Prints the players data of a specific directory.";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
            Optional = true;
        },
        {
            Type = "dataDirectory";
            Name = "Data Directory";
            Description = "The data directory.";
            Optional = true;
        }
    }
}