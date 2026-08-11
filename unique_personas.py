import json
import glob
import os

personas = {
    "amb_market1": [
        "Keep your hands where I can see them.",
        "Everyone's a thief until proven otherwise, that's my motto.",
        "You break it, you buy it. And it'll cost you double.",
        "I swear half my stock went missing before noon."
    ],
    "amb_market2": [
        "Oh! Do you know if anyone here sells cardamom?",
        "I just love market day! The colors, the smells, the crowds!",
        "I heard Silas is buying up all the fresh eggs.",
        "It's so hard to find good silk this far north."
    ],
    "amb_market3": [
        "Don't touch that! Put it down right now!",
        "I take my eyes off them for one second...",
        "I'm too tired to haggle today. Just take the coin.",
        "If you see a little boy with a wooden sword, tell him his mother is looking for him."
    ],
    "amb_crafts1": [
        "Borin's work is sloppy. Someday I'll have my own forge and show them all.",
        "I could forge a better blade blindfolded.",
        "They make me sweep the soot while true talent goes to waste.",
        "Don't buy the ironwork here. Wait until I set up shop."
    ],
    "amb_crafts2": [
        "EH? SPEAK UP! THE HAMMERS RUINED MY EARS!",
        "WHAT? YOU WANT A BUCKET?",
        "I SAID PINE, NOT OAK!",
        "CAN'T HEAR A THING YOU'RE SAYING, STRANGER!"
    ],
    "amb_old1": [
        "Before the mine closed, this square was paved with silver...",
        "The youth today have no respect for the old ways.",
        "I remember when Bramblewick was just three huts and a pig.",
        "They don't build houses like they used to."
    ],
    "amb_old2": [
        "The stones are watching us. I can feel it.",
        "There's old blood beneath these cobbles. Very old blood.",
        "Have you seen the shadows move when the sun stands still?",
        "Don't step on the cracks. It wakes them up."
    ],
    "amb_river1": [
        "Shh. You'll scare the fish.",
        "I've been sitting here since dawn and haven't had a single bite.",
        "If I close my eyes, I'm technically still fishing.",
        "Maybe the fish are sleeping too."
    ],
    "amb_river2": [
        "Look how the light catches the ripples...",
        "There's something deeply poetic about the river's endless journey.",
        "I come here to think. It's so peaceful.",
        "I wrote a sonnet about that duck over there."
    ],
    "amb_civic1": [
        "State your business, traveler. We don't like trouble.",
        "Keep your weapons sheathed, or I'll sheathe them for you.",
        "I've got my eye on you.",
        "No loitering. Move along."
    ],
    "amb_civic2": [
        "The mayor's taxes are steep... but a small donation to the guards might speed up your paperwork.",
        "Justice is blind, but occasionally she peeks if the coin is shiny enough.",
        "It's a tough job. A man's gotta eat, right?",
        "If you want access to the archives, it's going to cost you a 'processing fee'."
    ],
    "amb_outskirts1": [
        "Did you hear that? From the trees?",
        "I don't go near the Darkwood. Not since last winter.",
        "We should build the fences higher. Much higher.",
        "Sometimes at night, I hear voices calling from the tree line."
    ],
    "amb_outskirts2": [
        "Enjoy the quiet while it lasts. Adventure always finds you eventually.",
        "I used to carry a sword like that. Took an arrow to the knee, though.",
        "The smell of the wild... reminds me of my younger days.",
        "If I were ten years younger, I'd go into the woods with you."
    ]
}

for npc_id, lines in personas.items():
    fn = f"data/dialogue/{npc_id}.json"
    if os.path.exists(fn):
        with open(fn, "r", encoding="utf-8") as f:
            d = json.load(f)
        
        d["nodes"]["start"]["text"] = lines
        
        with open(fn, "w", encoding="utf-8") as f:
            json.dump(d, f, indent=4)
            
print("Injected unique personas for all 13 ambient NPCs.")
