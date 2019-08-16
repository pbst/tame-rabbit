#!/usr/bin/env python3

import os
import sys
import argparse


def main(challenge_dir):
    challenge_dir = os.path.abspath(challenge_dir)
    print(challenge_dir)
    assert os.path.isdir(challenge_dir)

    fuzzers = os.listdir(challenge_dir)
    for fuzzer in fuzzers:
        fuzzer_dir = os.path.join(challenge_dir, fuzzer)
        runs = os.listdir(fuzzer_dir)
        print("{} ({} runs)".format(fuzzer, len(runs)))
        for run in runs:
            run_dir = os.path.join(fuzzer_dir, run)
            crashids_filename = os.path.join(run_dir, "crashids.txt")
            if not os.path.isfile(crashids_filename):
                print("missing file: {}".format(crashids_filename))
                exit(1)
            ids = set()
            with open(crashids_filename, "r") as cf:
                for line in cf:
                    ids.add(int(line.split(" ")[0]))
            print("\t", len(ids))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='generate fuzzer run summaries for one challenge')
    parser.add_argument('challenge_dir', help='challenge dir')
    args = parser.parse_args()
    main(args.challenge_dir)
