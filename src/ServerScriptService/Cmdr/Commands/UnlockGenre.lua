return {
    Name = "unlockGenre";
    Aliases = { "ug" };
    Description = "Unlock a new genre";
    Group = "Admin";
    Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "The player.";
            Optional = true;
        }
    }
}