return {
    Name = "levelUpComputer";
    Aliases = { "luc" };
    Description = "Level up your computer";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
            Optional = true;
        },
    }
}