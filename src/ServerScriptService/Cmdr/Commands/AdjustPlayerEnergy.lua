return {
    Name = "adjustPlayerEnergy";
    Aliases = { "apd" };
    Description = "Adjust the players energy need,";
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