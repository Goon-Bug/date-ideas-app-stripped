import json
import sys


def combine_json_files(input_files, output_file):
    combined_data = []

    for file_path in input_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, list):
                combined_data.extend(data)
            else:
                print(f"Warning: {file_path} does not contain a list at the root.")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(combined_data, f, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python combine_json.py output.json input1.json input2.json ...")
        sys.exit(1)

    output = sys.argv[1]
    inputs = sys.argv[2:]
    combine_json_files(inputs, output)
    print(f"Combined {len(inputs)} files into {output}")
