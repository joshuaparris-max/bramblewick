import json
import glob
import os

flavor_pool = {
    "amb_market": [
        "Beautiful day for a bargain, isn't it?",
        "I've been looking for fresh apples all morning.",
        "Keep a hand on your coin purse. Lots of strangers about.",
        "The prices here just keep going up!",
        "Did you see the latest shipment from the south?",
        "If you're buying, make sure to haggle. They expect it."
    ],
    "amb_crafts": [
        "Watch your step, lots of sharp tools around here.",
        "The ringing of the anvils gives me a headache by noon.",
        "Borin does good work, if you can afford his silver.",
        "The wood here is still green. Takes forever to dry.",
        "Smells like pine and hot iron.",
        "Mind the sparks!"
    ],
    "amb_old": [
        "These old stones have seen better days...",
        "The village elder looks more tired every day.",
        "This part of town used to be the main square, long ago.",
        "Shadows get long here in the afternoon.",
        "Quiet around here, isn't it? Just how I like it.",
        "Watch the cobbles, some of them are loose."
    ],
    "amb_river": [
        "The water's calm today. Good for fishing.",
        "Old Sal hasn't taken the ferry out yet.",
        "I swear I saw something moving in the reeds yesterday.",
        "The breeze off the water is freezing at night.",
        "Careful near the bank, the mud is slippery.",
        "Nothing like the sound of the river to clear your head."
    ],
    "amb_civic": [
        "Keep your nose clean, the guards are watching.",
        "I need to pay my taxes before the week is out.",
        "The mayor hasn't made a speech in a month.",
        "This square is usually busier on weekends.",
        "Don't loiter too long near the town hall.",
        "Have you checked the notice board recently?"
    ],
    "amb_outskirts": [
        "I wouldn't wander too far past the town borders if I were you.",
        "The Darkwood has been restless lately.",
        "We're the first line if anything comes out of the forest.",
        "The wind always howls through these fences.",
        "You an adventurer? We get a lot of your kind passing through.",
        "Keep your sword loose in its scabbard out here."
    ]
}

for fn in glob.glob("data/dialogue/amb_*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        d = json.load(f)
    
    # get prefix
    m = os.path.basename(fn).replace(".json", "")
    prefix = m[:-1]
    
    pool = flavor_pool.get(prefix, ["Hello there."])
    
    d["nodes"]["start"]["text"] = pool
    
    with open(fn, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=4)
        
print("Updated ambient dialogues with varied flavor text pools.")
