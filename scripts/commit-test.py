# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

import re
import argparse


def extract_committed_blocks(filename):
    pattern = r"Committed block: \((\d+), (\d+)\)"
    committed_blocks = []

    with open(filename, 'r') as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                a, b = int(match.group(1)), int(match.group(2))
                committed_blocks.append((a, b))
    # print number of committed blocks in the filename
    print(f"Number of committed blocks in {filename}: {len(committed_blocks)}")
    return committed_blocks


def check_files(file_list):
    all_committed_blocks = [extract_committed_blocks(file) for file in file_list]

    lengths = [len(blocks) for blocks in all_committed_blocks]

    if all(length == lengths[0] for length in lengths):
        # All lengths are equal, check if they all have the same sequence
        first_sequence = all_committed_blocks[0]
        for file_index, sequence in enumerate(all_committed_blocks[1:], start=1):
            for i, seq_tuple in enumerate(sequence):
                if seq_tuple != first_sequence[i]:
                    print(f"Mismatch at index {i} between {file_list[0]} and {file_list[file_index]}")
                    return False
        return True
    else:
        # Find the maximum length sequence and its file name
        max_length = max(lengths)
        max_length_index = lengths.index(max_length)
        max_length_sequence = all_committed_blocks[max_length_index]
        max_length_file = file_list[max_length_index]

        # Check if all sequences are prefix of the max length sequence
        for file_index, sequence in enumerate(all_committed_blocks):
            for i in range(len(sequence)):
                if sequence[i] != max_length_sequence[i]:
                    print(f"Mismatch at index {i} between {file_list[file_index]} and {max_length_file}")
                    return False
        return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some files.')
    parser.add_argument('files', metavar='F', type=str, nargs='+', help='a list of files to process')

    args = parser.parse_args()
    file_list = args.files

    result = check_files(file_list)
    if result:
        print("Safety achieved")
    else:
        print("Safety lost")
