return {
    Name = "unlockTopic";
    Aliases = { "ut" };
    Description = "Unlock a new topic";
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