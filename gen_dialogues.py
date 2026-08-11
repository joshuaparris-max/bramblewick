import json
import os

missing = [
    "amb_market1", "amb_market2", "amb_market3",
    "amb_crafts1", "amb_crafts2",
    "amb_old1", "amb_old2",
    "amb_river1", "amb_river2",
    "amb_civic1", "amb_civic2",
    "amb_outskirts1", "amb_outskirts2"
]

flavor_texts = {
    "amb_market": "Beautiful day for a bargain, isn't it?",
    "amb_crafts": "Watch your step, lots of sharp tools around here.",
    "amb_old": "These old stones have seen better days...",
    "amb_river": "The water's calm today. Good for fishing.",
    "amb_civic": "Keep your nose clean, the guards are watching.",
    "amb_outskirts": "I wouldn't wander too far past the town borders if I were you."
}

for m in missing:
    prefix = m[:-1] # drop the number
    text = flavor_texts.get(prefix, "Hello there.")
    
    d = {
        "id": m,
        "nodes": {
            "root": {
                "text": text,
                "options": [
                    {
                        "label": "Goodbye.",
                        "jump": "leave"
                    }
                ]
            }
        }
    }
    with open(f"data/dialogue/{m}.json", "w", encoding="utf-8") as f:
        json.dump(d, f, indent=4)

print("Created 13 missing dialogues.")
