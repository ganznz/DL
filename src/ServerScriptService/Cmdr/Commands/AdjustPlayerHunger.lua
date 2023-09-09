return {
    Name = "adjustPlayerHunger";
    Aliases = { "aph" };
    Description = "Adjust the players hunger need,";
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