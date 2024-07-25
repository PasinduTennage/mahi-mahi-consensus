import re
import argparse


def extract_created_blocks(filename):
    pattern = r"Created block ([A-Z])(\d+)"
    created_blocks = []

    with open(filename, 'r') as file:
        for line in file:
            match = re.match(pattern, line)
            if match:
                letter, number = match.groups()
                number = int(number)
                created_blocks.append((letter, number))
    # print number of created blocks in the filename
    print(f"Number of created blocks in {filename}: {len(created_blocks)}")
    return created_blocks


def check_blocks(blocks):
    if not blocks:
        return True, None

    first_letter = blocks[0][0]
    previous_number = blocks[0][1]

    for i, (letter, number) in enumerate(blocks[1:], start=1):
        if letter != first_letter:
            return False, f"Mismatch at index {i}: Expected letter {first_letter}, found {letter} at number {number}"
        if number != previous_number + 1:
            return False, f"Mismatch at index {i}: Expected number {previous_number + 1}, found {number}"
        previous_number = number

    return True, None


def process_files(file_list):
    all_results = []
    for filename in file_list:
        blocks = extract_created_blocks(filename)
        is_correct, error = check_blocks(blocks)
        if not is_correct:
            all_results.append(f"File {filename} is incorrect: {error}")
        else:
            all_results.append(f"File {filename} is correct.")
    return all_results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('files', metavar='F', type=str, nargs='+', help='a list of files to process')

    args = parser.parse_args()
    file_list = args.files

    results = process_files(file_list)
    for result in results:
        print(result)
