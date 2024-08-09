import re
import sys

def count_patterns_in_file(filename):
    commit_count = 0
    skip_count = 0
    undecided_count = 0

    with open(filename, 'r') as file:
        for line in file:
            if re.search(r'Commit\(\w+\)', line):
                commit_count += 1
            elif re.search(r'Skip\(\w+\)', line):
                skip_count += 1
            elif re.search(r'Undecided\(\w+\)', line):
                undecided_count += 1

    return commit_count, skip_count, undecided_count

def process_logs(file_list):
    total_commit = 0
    total_skip = 0
    total_undecided = 0

    for file in file_list:
        commit, skip, undecided = count_patterns_in_file(file)
        total_commit += commit
        total_skip += skip
        total_undecided += undecided

    print(f"Total Commit(X): {total_commit}")
    print(f"Total Skip(X): {total_skip}")
    print(f"Total Undecided(X): {total_undecided}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <logfile1> <logfile2> <logfile3> <logfile4>")
        sys.exit(1)

    log_files = sys.argv[1:]

    process_logs(log_files)
