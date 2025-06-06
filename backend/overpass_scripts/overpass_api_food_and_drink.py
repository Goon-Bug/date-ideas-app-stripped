import requests
import json
import re

OVERPASS_URL = "http://overpass-api.de/api/interpreter"

# Liverpool bounding box
bbox = (53.3811, -3.0390, 53.4666, -2.8434)

# Amenities in Food & Drink section
amenities = [
    "restaurant",
    "cafe",
    "fast_food",
    "pub",
    "bar",
    "food_court",
    "biergarten"
]

# Construct Overpass query for multiple amenities
amenities_filter = "".join(
    f'node["amenity"="{a}"]({bbox[0]},{bbox[1]},{bbox[2]},{bbox[3]});' for a in amenities
)

query = f"""
[out:json][timeout:25];
(
  {amenities_filter}
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
    "restaurant": "Dine at {name}, a charming restaurant{cuisine_clause}.",
    "cafe": "Visit {name}, a cozy local café{cuisine_clause}.",
    "fast_food": "Grab a quick bite at {name}, a popular fast food spot{cuisine_clause}.",
    "pub": "Relax at {name}, a friendly pub offering great drinks{cuisine_clause}.",
    "bar": "Enjoy a night out at {name}, a lively bar{cuisine_clause}.",
    "food_court": "Explore {name}, a bustling food court with various options{cuisine_clause}.",
    "biergarten": "Spend time at {name}, a traditional biergarten serving refreshing beverages{cuisine_clause}."
}


def estimate_cost(cuisine, amenity):
    low_cost_cuisines = {"fast_food", "burger", "cafe", "bakery", "sandwich", "pizza"}
    high_cost_cuisines = {"french", "steak_house", "sushi", "fine_dining", "gourmet", "wine"}

    cuisine = cuisine.lower() if cuisine else ""
    amenity = amenity.lower() if amenity else ""

    if cuisine in low_cost_cuisines:
        return "Low"
    elif cuisine in high_cost_cuisines:
        return "High"
    else:
        # fallback based on amenity type
        if amenity == "fast_food":
            return "Low"
        elif amenity in {"restaurant", "bar", "pub", "biergarten"}:
            return "Medium"
        else:
            return "Medium"


# Map amenity to duration in hours
duration_map = {
    "restaurant": 1.5,
    "cafe": 1,
    "fast_food": 0.75,
    "pub": 1,
    "bar": 1,
    "food_court": 1,
    "biergarten": 1.25
}

aggregated = {}

for el in elements:
    tags = el.get("tags", {})
    name = tags.get("name")
    website = tags.get("website")
    amenity = tags.get("amenity")

    # Skip entries without a name, amenity, or website
    if not name or not amenity or not website:
        continue

    street = tags.get("addr:street", "")
    city = tags.get("addr:city", "Liverpool")
    postcode = tags.get("addr:postcode", "")
    cuisine = tags.get("cuisine", "")
    brand = tags.get("brand", "")
    wheelchair = tags.get("wheelchair", "")

    location_parts = [street, city, postcode]
    location = ", ".join([part for part in location_parts if part]) or f"{el.get('lat')}, {el.get('lon')}"

    cuisine_clause = f" serving {cuisine} cuisine" if cuisine else ""

    # Build description from template
    template = description_templates.get(
        amenity,
        "Visit {name}, a great place to enjoy food and drinks{cuisine_clause}."
    )
    description = template.format(name=name, cuisine_clause=cuisine_clause)
    description = clean_text(description)

    tag_list = ["food", "indoor", "budget-friendly"]
    if cuisine:
        tag_list.append(clean_tag(cuisine))
    if wheelchair == "yes":
        tag_list.append("wheelchair accessible")

    disallowed = {"coffee_shop", "branded", "sandwich"}
    tag_list = [tag for tag in tag_list if tag not in disallowed]
    tag_list = [clean_text(tag) for tag in tag_list]

    cost = estimate_cost(cuisine, amenity)

    # Use duration_map, default to 1 if amenity not in map
    duration = duration_map.get(amenity, 1)

    if name not in aggregated:
        aggregated[name] = {
            "title": name,
            "description": description,
            "locations": set([location]),
            "duration": duration,
            "cost": cost,
            "tags": set(tag_list),
            "websites": set([website])
        }
    else:
        aggregated[name]["tags"].update(tag_list)
        aggregated[name]["websites"].add(website)
        aggregated[name]["locations"].add(location)

        # Update cost to the highest between existing and new
        cost_priority = {"Low": 1, "Medium": 2, "High": 3}
        existing_cost = aggregated[name]["cost"]
        if cost_priority[cost] > cost_priority.get(existing_cost, 0):
            aggregated[name]["cost"] = cost

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

with open("backend/jsons/date_ideas_liverpool_food_drink.json", "w", encoding="utf-8") as f:
    json.dump(date_ideas, f, ensure_ascii=False, indent=2)

print(f"Saved {len(date_ideas)} date ideas to date_ideas_liverpool_food_drink.json")
