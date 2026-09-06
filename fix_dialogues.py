import json
import glob
import os

fixed_count = 0
for fn in glob.glob("data/dialogue/*.json"):
    with open(fn, "r", encoding="utf-8") as f:
        d = json.load(f)
    
    modified = False
    
    # fix root node name
    if "nodes" in d:
        if "root" in d["nodes"] and "start" not in d["nodes"]:
            d["nodes"]["start"] = d["nodes"].pop("root")
            modified = True
        
        # fix nodes
        for node_id, node in d["nodes"].items():
            if "options" in node:
                node["choices"] = node.pop("options")
                modified = True
            
            for c in node.get("choices", []):
                if "jump" in c:
                    c["next"] = c.pop("jump")
                    if c["next"] == "leave":
                        c["next"] = None
                    modified = True
                    
    if modified:
        with open(fn, "w", encoding="utf-8") as f:
            json.dump(d, f, indent=4)
        print(f"Fixed {os.path.basename(fn)}")
        fixed_count += 1

print(f"Fixed {fixed_count} dialogue files.")
