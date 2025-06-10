import json
from pathlib import Path


def combine_json_from_folder(folder_path, output_file):
    combined_data = []
    folder = Path(folder_path)

    # Find all .json files in the folder
    json_files = list(folder.glob("*.json"))
    if not json_files:
        print(f"No JSON files found in folder: {folder_path}")
        return

    for file_path in json_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, list):
                combined_data.extend(data)
            else:
                print(f"Warning: {file_path} does not contain a list at the root.")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(combined_data, f, indent=2, ensure_ascii=False)
    print(f"Combined {len(json_files)} JSON files into {output_file}")


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python combine_json_folder.py <folder_path> <output_file.json>")
        exit(1)

    folder_path = sys.argv[1]
    output_file = sys.argv[2]
    combine_json_from_folder(folder_path, output_file)
