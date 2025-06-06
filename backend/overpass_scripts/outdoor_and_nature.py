import requests
import json
import re

OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Outdoor / nature amenities filters
filters = [
    '["leisure"="park"]',
    '["leisure"="fountain"]',
    '["tourism"="picnic_site"]',
    '["leisure"="garden"]',
    '["tourism"="zoo"]',
    '["tourism"="aquarium"]',
    '["amenity"="animal_shelter"]',
    '["nature"="nature_reserve"]',
    '["tourism"="beach_resort"]'
]

# Build filters block for Overpass query
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


# Description templates per amenity
description_templates = {
    "park": "Relax and enjoy nature at {name}, a beautiful local park.",
    "fountain": "Visit {name}, a charming fountain to admire and unwind by.",
    "picnic_site": "Have a delightful picnic at {name}, perfect for outdoor dining.",
    "garden": "Stroll through {name}, a peaceful and scenic garden.",
    "zoo": "Discover fascinating wildlife at {name}, a family-friendly zoo.",
    "aquarium": "Explore marine life at {name}, an educational aquarium.",
    "animal_shelter": "Support and visit {name}, a caring animal shelter.",
    "nature_reserve": "Experience wildlife and nature at {name}, a protected nature reserve.",
    "beach_resort": "Enjoy sun and sea at {name}, a relaxing beach resort."
}

# Estimated visit durations (hours)
duration_map = {
    "park": 2,
    "fountain": 0.5,
    "picnic_site": 2,
    "garden": 1.5,
    "zoo": 3,
    "aquarium": 2,
    "animal_shelter": 1,
    "nature_reserve": 3,
    "beach_resort": 4
}

# Custom tag mapping (if needed)
custom_tag_map = {
    "picnic_site": "picnic",
    "animal_shelter": "animal care",
    "nature_reserve": "nature"
}

aggregated = {}

for el in elements:
    tags = el.get("tags", {})
    name = tags.get("name")
    website = tags.get("website")

    # Determine amenity type from tags, priority order
    amenity = (
        tags.get("leisure") or
        tags.get("tourism") or
        tags.get("amenity") or
        tags.get("nature")
    )
    if not name or not amenity:
        continue

    street = tags.get("addr:street", "")
    city = tags.get("addr:city", "Liverpool")
    postcode = tags.get("addr:postcode", "")
    wheelchair = tags.get("wheelchair", "")

    location_parts = [street, city, postcode]
    location = ", ".join([part for part in location_parts if part]) or f"{el.get('lat')}, {el.get('lon')}"

    template = description_templates.get(amenity, "Visit {name}, a wonderful outdoor spot in Liverpool.")
    description = clean_text(template.format(name=name))

    tag_name = custom_tag_map.get(amenity, clean_tag(amenity))
    tag_list = ["outdoor", tag_name]
    if wheelchair == "yes":
        tag_list.append("wheelchair accessible")

    # Cost is usually low or free for these amenities
    cost = "Low"
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

# Final output list
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

with open("backend/jsons/date_ideas_liverpool_outdoor.json", "w", encoding="utf-8") as f:
    json.dump(date_ideas, f, ensure_ascii=False, indent=2)

print(f"Saved {len(date_ideas)} outdoor date ideas to date_ideas_liverpool_outdoor.json")
