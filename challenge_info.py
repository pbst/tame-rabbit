#!/usr/bin/env python3

# transform rode0day style info.yaml into a shell source-able info file per challenge

import yaml
import os

def transform(challenge_path):
    challenge_path = os.path.abspath(challenge_path)
    os.stat(challenge_path)
    challenge_name = os.path.basename(challenge_path)

    infoyaml_path = os.path.abspath(os.path.join(challenge_path, "..", "info.yaml"))

    with open(infoyaml_path, "r") as infoyaml:
        data = yaml.load(infoyaml.read())
    challenge_data = data["challenges"][challenge_name]

    if challenge_data["source_provided"]:
        challenge_data["BINARY_PREFIX"] = "/challenge/rebuilt"
    else:
        challenge_data["BINARY_PREFIX"] = "/challenge/built"

    challenge_data["binary_path"] = challenge_data["binary_path"].replace("rebuilt/", "").replace("built/", "")

    # HACK
    challenge_data["binary_arguments"] = challenge_data["binary_arguments"].replace("{install_dir}", "/challenge/built/").format(input_file="@@")

    for k in challenge_data:
        line = "{}=\"{}\"".format(k.upper(), challenge_data[k])
        print(line)

def main(argv):
    if len(argv) != 2:
        print(f"usage: {argv[0]} path/to/challenge")
        exit(1)
    transform(argv[1])

if __name__ == "__main__":
    import sys
    main(sys.argv)
