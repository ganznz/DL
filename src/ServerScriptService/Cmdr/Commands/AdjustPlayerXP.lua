return {
    Name = "adjustPlayerXP";
    Aliases = { "apx" };
    Description = "Adjust the players XP";
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