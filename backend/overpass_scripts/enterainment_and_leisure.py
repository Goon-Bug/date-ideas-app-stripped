import requests
import json
import re

OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Amenity filters
filters = [
    '["amenity"="cinema"]',
    '["amenity"="theatre"]',
    '["amenity"="arts_centre"]',
    '["leisure"="arts_centre"]',
    '["amenity"="nightclub"]',
    '["amenity"="casino"]',
    '["tourism"="planetarium"]'
]

# Create the Overpass query using Liverpool as an administrative area
filters_block = "\n".join(
    f"{type_}{f}(area.searchArea);" for f in filters for type_ in ["node", "way", "relation"]
)


query = f"""
[out:json][timeout:25];
area["name"="Liverpool"]["boundary"="administrative"]->.searchArea;
(
{''.join(filters_block)}
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


# Description templates per amenity
description_templates = {
    "cinema": "Watch the latest films at {name}, a top-rated cinema experience.",
    "theatre": "Enjoy a live performance at {name}, a local theatre with rich programming.",
    "arts_centre": "Explore creative exhibitions and events at {name}, a vibrant arts centre.",
    "nightclub": "Dance the night away at {name}, one of Liverpool’s energetic nightclubs.",
    "casino": "Try your luck at {name}, a stylish casino with entertainment and games.",
    "planetarium": "Stargaze at {name}, an educational and awe-inspiring planetarium."
}

# Estimated visit durations (in hours)
duration_map = {
    "cinema": 2,
    "theatre": 2.5,
    "arts_centre": 1.5,
    "nightclub": 3,
    "casino": 2,
    "planetarium": 1.5
}

# Custom tag mapping
custom_tag_map = {
    "arts_centre": "art",
}

aggregated = {}

for el in elements:
    tags = el.get("tags", {})
    name = tags.get("name")
    website = tags.get("website")

    amenity = tags.get("amenity") or tags.get("leisure") or tags.get("tourism")
    if not name or not amenity:
        continue

    street = tags.get("addr:street", "")
    city = tags.get("addr:city", "Liverpool")
    postcode = tags.get("addr:postcode", "")
    wheelchair = tags.get("wheelchair", "")

    location_parts = [street, city, postcode]
    location = ", ".join([part for part in location_parts if part]) or f"{el.get('lat')}, {el.get('lon')}"

    template = description_templates.get(amenity, "Visit {name}, a unique entertainment venue in Liverpool.")
    description = clean_text(template.format(name=name))

    tag_name = custom_tag_map.get(amenity, clean_tag(amenity))
    tag_list = ["entertainment", tag_name]
    if wheelchair == "yes":
        tag_list.append("wheelchair accessible")

    cost = "Medium" if amenity in {"cinema", "planetarium", "arts_centre"} else "High"
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

        cost_priority = {"Low": 1, "Medium": 2, "High": 3}
        existing_cost = aggregated[name]["cost"]
        if cost_priority[cost] > cost_priority.get(existing_cost, 0):
            aggregated[name]["cost"] = cost

# Final output
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

with open("backend/jsons/date_ideas_liverpool_entertainment.json", "w", encoding="utf-8") as f:
    json.dump(date_ideas, f, ensure_ascii=False, indent=2)

print(f"Saved {len(date_ideas)} date ideas to date_ideas_liverpool_entertainment.json")
