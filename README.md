

# WHAT?


This project packages fuzzers in Docker containers, creates a somewhat unified
interface between them, and provides glue scripts to let them run against a
bunch of challenges.

The aim is to provide an easy to extend base that allows everyone to integrate
and evaluate their fuzzers against a set of challenges that is extensible as
well.

Currently available targets are rode0day challenges with minor changes.

This project is highly experimental conventions are subject to change. Any
feedback is appreciated.


# USAGE


1. Build all docker images (run `./build_docker_images.sh`)
2. Ensure your `sysctl` settings allow AFL and others to properly run. (see `afl-system-config` script from the [AFLplusplus](https://github.com/vanhauser-thc/AFLplusplus) project)
3. Start fuzzing a challenge with a single fuzzer `./run_one.sh challenge_name fuzzer_name` or run all available fuzzers against one challenge `./run_all.sh challenge_name`.
4. After a successful run the output directories are placed in `./out/` for further analysis.


# HOW DOES IT WORK?


For each fuzzer and mode that is to be tested a docker image with an
appropriate name has to be created.  Look into `./docker/fuzzer_*` for examples.

The `fuzzer_` prefix is for fuzzers that are ready to be used, `base_` prefix
indicates Docker base images that contain some common stuff and are used as
building blocks for other images.

The fuzzer images are supposed to be used interchangeably. Therefore a somewhat
unified interface is required. This is done via file system conventions.

The following chapters try to give a higher level overview.

## volumes

Directories are mapped into the container at certain paths:

- `/out` used for the AFL sync directory plus some extra (meta)data
- `/challenge` contains source that can be build with with make

## one run

One run consists of different phases. For each phase the volumes are
mapped into the container and the helper scripts for each phase get executed.

1. prepare phase: build target and collect some metadata
2. fuzz phase: run fuzzer against target for a predefined amount of time
3. eval phase: validate crashes

## output directory

After a successful run, the `/out/` directory is archived in `./out/` following the scheme:

`./out/$challenge_name/$fuzzer_name_with_mode/$unixtimestamp/`

## challenges

This challenges are in a seperate repository and have to be copied manually to
`./challenges`.

The directory is roughly structured after this:

- `./challenges/$setid/info.yaml` rode0day compatible info file for challenges below this directory
- `./challenges/$setid/$challenge_name/` challenge directory. What you would find in rode0day 'download'
- `./challenges/$setid/$challenge_name/build.sh` script to build challenge binary from source
- `./challenges/$setid/$challenge_name/src/` challenge source

- `./challenges/$setid/$challenge_name/src.lavalog/` lavalog instrumented source
- `./challenges/$setid/$challenge_name/{,re}built.lavalog/` lavalog instrumented binary directory
- `./challenges/$setid/$challenge_name/crashes/` solutions that trigger all known bugs

To properly verify bugs make sure the `built.lavalog` directory contains a
lavalog enabled binary. A lavalog enabled binary can be produced by setting
`CFLAGS=-DLAVA_LOGGING` when building. Also make sure to use the sources that
still contain the lavalog macros.

For rode0day imported challenges `$setid` format is `YY.MM` (Y for year, and M
for month). Challenge names are globally unique.

## hacking

For debugging purposes `fuzzit.sh` will drop you into a shell before each
phase is executed if `MANUAL=1` environment variable is defined.


# ISSUES / LIMITATIONS


- Running fuzz jobs requires a lot of time and resources.
- Very low number of bugs are found with current setup. Maybe there are some serious issues or the length of a single run just needs to be extended.
- Currently only fuzzers compatible with AFL are supported.
- Angora fuzzer requires to build the target twice. So make sure the `build.sh` script cleans up properly before each build.
