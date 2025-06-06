import requests
import json
import re

OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Sports and leisure amenities filters
filters = [
    '["leisure"="sports_centre"]',
    '["leisure"="ice_rink"]',
    '["leisure"="swimming_pool"]',
    '["leisure"="gym"]',
    '["leisure"="leisure_centre"]',
    '["leisure"="miniature_golf"]',
    '["leisure"="bowling_alley"]',
    '["leisure"="escape_game"]',
    '["amenity"="bicycle_rental"]',
    '["leisure"="climbing_adventure"]'
]

filters_block = "\n".join(
    f"{type_}{f}(area.searchArea);" for f in filters for type_ in ["node", "way", "relation"]
)

query = f"""
[out:json][timeout:25];
area["name"="Liverpool"]["boundary"="administrative"]->.searchArea;
(
{filters_block}
);
out tags center;
"""

response = requests.post(OVERPASS_URL, data={"data": query})
data = response.json()
elements = data.get("elements", [])

def clean_text(text):
    return re.sub(r"[_;]", " ", text).strip()

def clean_tag(tag):
    return clean_text(tag.lower())

description_templates = {
    "sports_centre": "Stay active at {name}, a well-equipped sports centre.",
    "ice_rink": "Enjoy skating at {name}, a fun ice rink for all ages.",
    "swimming_pool": "Swim some laps or relax at {name}, a public swimming pool.",
    "gym": "Keep fit at {name}, a modern gym with great facilities.",
    "leisure_centre": "Have fun and stay fit at {name}, a popular leisure centre.",
    "miniature_golf": "Challenge friends at {name}, a fun miniature golf course.",
    "bowling_alley": "Strike some pins at {name}, a lively bowling alley.",
    "escape_game": "Test your wits at {name}, an exciting escape game venue.",
    "bicycle_rental": "Explore Liverpool with {name}, a convenient bicycle rental spot.",
    "climbing_adventure": "Reach new heights at {name}, a thrilling climbing adventure."
}

duration_map = {
    "sports_centre": 2,
    "ice_rink": 1.5,
    "swimming_pool": 2,
    "gym": 1.5,
    "leisure_centre": 2,
    "miniature_golf": 1.5,
    "bowling_alley": 2,
    "escape_game": 1.5,
    "bicycle_rental": 1,
    "climbing_adventure": 2
}

custom_tag_map = {
    "sports_centre": "sports",
    "ice_rink": "ice skating",
    "swimming_pool": "swimming",
    "gym": "fitness",
    "leisure_centre": "leisure",
    "miniature_golf": "mini golf",
    "bowling_alley": "bowling",
    "escape_game": "escape game",
    "bicycle_rental": "bicycle rental",
    "climbing_adventure": "climbing"
}

aggregated = {}

for el in elements:
    tags = el.get("tags", {})
    name = tags.get("name")
    website = tags.get("website")

    # Determine amenity type
    amenity = (
        tags.get("leisure") or
        tags.get("amenity")
    )
    if not name or not amenity:
        continue

    street = tags.get("addr:street", "")
    city = tags.get("addr:city", "Liverpool")
    postcode = tags.get("addr:postcode", "")
    wheelchair = tags.get("wheelchair", "")

    location_parts = [street, city, postcode]
    location = ", ".join([part for part in location_parts if part]) or f"{el.get('lat')}, {el.get('lon')}"

    template = description_templates.get(amenity, "Visit {name}, a fantastic leisure venue in Liverpool.")
    description = clean_text(template.format(name=name))

    tag_name = custom_tag_map.get(amenity, clean_tag(amenity))
    tag_list = ["leisure", tag_name]
    if wheelchair == "yes":
        tag_list.append("wheelchair accessible")

    cost = "Medium"
    duration = duration_map.get(amenity, 1.5)

    if name not in aggregated:
        aggregated[name] = {
            "title": name,
            "description": description,
            "locations": set([location]),
            "duration": duration,
            "cost": cost,
            "tags": set(tag_list),
            "websites": set([website]) if website else set()
        }
    else:
        aggregated[name]["tags"].update(tag_list)
        if website:
            aggregated[name]["websites"].add(website)
        aggregated[name]["locations"].add(location)

date_ideas = []
for item in aggregated.values():
    date_ideas.append({
        "title": item["title"],
        "description": item["description"],
        "locations": sorted(list(item["locations"])),
        "duration": item["duration"],
        "cost": item["cost"],
        "tags": sorted(list(item["tags"])),
        "websites": sorted(list(item["websites"]))
    })

with open("backend/jsons/date_ideas_liverpool_leisure.json", "w", encoding="utf-8") as f:
    json.dump(date_ideas, f, ensure_ascii=False, indent=2)

print(f"Saved {len(date_ideas)} leisure date ideas to date_ideas_liverpool_leisure.json")
