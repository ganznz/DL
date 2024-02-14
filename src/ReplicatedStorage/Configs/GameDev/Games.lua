local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableHandler = require(ReplicatedStorage.Libs.TableHandler.TableHandler)

local Remotes = ReplicatedStorage.Remotes

local tableHandler = TableHandler.new()

-- contains methods that can be used on already developed games
local Games = {}
Games.__index = Games

Games.Reviews = {
    AuthorImageIDs = {
        "16284461747",
        "16284462749",
        "16284464072",
        "16284465081",
        "16284466137",
        "16284467444",
        "16284468416",
        "16284469899",
        "16284471105",
        "16284472017",
        "16284473585",
        "16284474709",
        "16284475643",
        "16284477461",
        "16284483882",
        "16284484632",
        "16284485931",
        "16284486594",
        "16284486594",
        "16284488351",
        "16284495635",
        "16284496696",
        "16284499666",
        "16284500646",
        "16284501884",
        "16284502857",
        "16284504058",
        "16284504881",
        "16284505635",
        "16284506340",
        "16284507429",
        "16284508539",
        "16284509617",
    },
    RecentlyUsedGenreTopic = {
        "This studio just released a GENRETOPIC game!",
        "Will you guys make anything other than a GENRETOPIC game?",
        "Another day, another generic GENRETOPIC release from this studio",
        "Seriously, is this studio allergic to creativity? Another GENRETOPIC game?",
        "At this point, I'm convinced they just have a GENRETOPIC generator",
        "What's next, another GENRETOPIC title from these devs?",
        "It's like they're stuck in a loop, churning out one GENRETOPIC game after another"
    },
    CompatibleGenreTopic = {
        "The combination of GENRE and TOPIC is great!",
        "A match made in gaming heaven! GENRE and TOPIC blend seamlessly",
        "Finally, a GENRE game that tackles the TOPIC theme in a refreshing way!",
        "GENRE game fans rejoice! This TOPIC twist adds a whole new layer of fun",
        "TOPIC meets GENRE in this thrilling fusion of gameplay and narrative",
    },
    IncompatibleGenreTopic = {
        "Unfortunately, the pairing of GENRE and the TOPIC theme falls flat",
        "It's like they tried to force GENRE and TOPIC together, and it just doesn't work",
        "The TOPIC theme feels out of place with the GENRE genre..",
        "I appreciate the attempt to innovate, but the combination of GENRE and TOPIC feels forced",
        "This game struggles to find its identity with the mismatch of GENRE and TOPIC",
    },
    ["1"] = {
        Informational = {
            Bugs = {
                "This game crashed my entire system. Buyer beware!",
                "Buggy mess! Glitches everywhere, unplayable",
                "Save your money, this game is riddled with bugs",
                "Constant freezes and crashes, no fun at all",
                "Seriously, did anyone even playtest this?",
            },
        },
        NonInformational = {
            "A regrettable purchase, avoid at all costs",
            "Not worth the download time",
            "Lacks polish and basic functionality",

        },
        Funny = {
            "My cat could make a better game. Avoid at all costs!",
            "I'd rather wrestle a bear than play this disaster",
            "This game is the reason I have trust issues",
            "I'd rather suffer in the 2008 financial crisis than play this game",
            "This game is the epitome of pain and suffering",
            "Bad/10"
        }
    },
    ["2"] = {
        Informational = {
            Bugs = {
                "Decent concept, but too many technical issues",
                "Fun for a bit, but the constant bugs ruin it",
                "Not bad, but the bugs make it frustrating",
                "Could have been good if they fixed the bugs",
                "Needs major patching before it's worth playing",
            },
        },
        NonInformational = {
            "Not the worst, but definitely not worth your time or money",
            "It's like they tried to make a game, but missed the mark",
        },
        Funny = {
            "If you enjoy frustration and disappointment, this is for you",
            "I've seen better games on a TI-83 calculator",
            "This game is like a bad joke that's not even funny",
            "I'd rather watch paint dry for 10 hours than play this",
            "This game gave me Alzheimers because it's so forgettable"
        }
    },
    ["3"] = {
        Informational = {
            Bugs = {
                "Enjoyable gameplay, but occasional glitches",
                "Playable, but some annoying bugs need fixing",
                "Decent game, just needs some polishing",
                "Good game, but could be great with bug fixes",
                "Overall solid, but minor bugs detract from the experience",
            },
        },
        NonInformational = {
            "Decent effort, but lacks originality",
            "Average game, nothing remarkable but not terrible either",
            "Had potential, but fell short in execution",

        },
        Funny = {
            "Well, it's technically a game, I guess?",
            "Meh, it killed some time.",
            "The voices... they're getting louder... THEY ARE SO LOUDYDGDFDFIFBD AHHHHHHH",
            "It's pretty good but I'm still choosing League over this any day (I don't shower)",
            "A great distraction from the crumbling of western society"
        }
    },
    ["4"] = {
        Informational = {
            Bugs = {
                "Almost perfect, just a few minor bugs here and there",
                "Great game, occasional bugs didn't ruin the fun",
                "Few bugs, but nothing game-breaking",
                "Smooth gameplay with only minor technical issues",
                "Fantastic game, just a couple of minor bugs to squash",
            },
        },
        NonInformational = {
            "Surprisingly good! Worth giving it a shot",
            "Solid gameplay and engaging mechanics",
            "A pleasant surprise from this developer",
            "Enjoyable experience, would recommend",
            "Well-crafted and entertaining. Thumbs up!",
        },
        Funny = {
            "Almost perfect! Just kidding, I still found a bug... it's called my inability to stop playing!",
            "Great game! I even called in 'sick' to work today so I could keep playing",
            "I'd give it 5 stars, but then the developers might get lazy. Gotta keep them on their toes!",
            "Four stars because my cat hasn't figured out how to play yet. Otherwise, flawless!",
            "Why isn't my favourite content creator playing this",
        }
    },
    ["5"] = {
        Informational = {
            Bugs = {
                "Flawless performance, no bugs in sight!",
                "Polished and bug-free, a rare gem in gaming",
                "Impeccably designed, not a single glitch",
                "Perfection achieved, no bugs to report",
                "Bug-free bliss, a masterpiece of game development",
            },
        },
        NonInformational = {
            "An absolute gem of a game! A must-play",
            "Pure gaming bliss. 10/10 would play again",
            "Outstanding work from start to finish",
            "Bravo! This game sets a new standard",
            "Perfection in digital form. Thank you, developers!",
        },
        Funny = {
            ":) :)))))))))))) :) :) :) :))))))) :D",
            "This game has me HOOKED, I HAVEN'T SLEPT IN DAYS!!!!",
            "Great game but you know what would make it better? A battle pass",
            "I haven't left the house in weeks..."
        }
    }
}

export type GameData = {
    Name: string,
    Genre: string,
    Topic: string,
    Points: { Code: number, Sound: number, Art: number },
    PointDistribution: "Even" | "Uneven",
    GenreTopicRelationship: "Compatible" | "Incompatible" | "Neutral",
    GenreTrending: boolean,
    TopicTrending: boolean,
    Sales: {
        Total: number,
        Weekly: { Week1: number, Week2: number, Week3: number, Week4: number }
    },
    Earnings: number,
    Reviews: {},
    Marketing: string | false
}

-- opts
---- MostRecent: number | nil -- returns the specified number of games, starting from 1st most recent, 2nd most recent, etc...
function Games.GetDevelopedGames(plrData: {}, opts: {}): {{GameData}}
    opts = opts or {}

    local developedGamesData = plrData.GameDev.DevelopedGames

    if opts["MostRecent"] then
        local numOfGames = opts.MostRecent
        if numOfGames >= #developedGamesData then
            return developedGamesData
        else
            local startIndex = #developedGamesData - opts["MostRecent"]
            local endIndex = #developedGamesData + 1
            return tableHandler:Slice(developedGamesData, startIndex, endIndex)
        end
    end

    return developedGamesData
end

-- function returns a list of the genre and topics used in the developed games provided
function Games.GetGenresTopics(developedGames: {}): { Genres: {}, Topics: {} }
    local genreNames = {}
    local topicNames = {}

    if #developedGames ~= 0 then
        for _i, gameData: GameData in developedGames do
            local gameGenre = gameData.Genre
            local gameTopic = gameData.Topic

            if not table.find(genreNames, gameGenre) then table.insert(genreNames, gameGenre) end
            if not table.find(topicNames, gameTopic) then table.insert(topicNames, gameTopic) end
        end
    end

    return { Genres = genreNames, Topics = topicNames }
end

-- function determines the genre/topic relationship of an unpublished game
function Games.GetGenreTopicRelationship(plrData: {}, usedGenre: string, usedTopic: string): "Neutral" | "Compatible" | "Incompatible"
    local areCompatible: boolean = plrData.GameDev.Genres[usedGenre].CompatibleWith == usedTopic
    local areIncompatible: boolean = plrData.GameDev.Genres[usedGenre].IncompatibleWith == usedTopic
    local relationship = "Neutral"
    if areCompatible then
        relationship = "Compatible"
    elseif areIncompatible then
        relationship = "Incompatible"
    end

    return relationship
end

return Games