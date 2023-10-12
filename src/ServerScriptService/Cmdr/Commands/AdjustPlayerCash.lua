return {
    Name = "adjustPlayerCash";
    Aliases = { "apc" };
    Description = "Adjust the players cash amount";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
            Optional = true;
        },
        {
            Type = "number";
            Name = "Amount";
            Description = "The amount you want to adjust by.";
            Optional = true;
        }
    }
}