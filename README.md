# Ruff benchmark

This repository hosts my benchmarking scripts to compare Ruff, Flake8, Black, and Pylint in linting and code formatting. From running the benchmark on my system here are the results:
```txt
# pygame snake game (small code base)
Ruff (linting) took 1.0 seconds
Flake8 (linting) took 2.0 seconds
Pylint (linting) took 1.0 seconds
Ruff (formatting) took 0 seconds
Black (formatting) took 9.0 seconds

# cpython (large code base)
Ruff (linting) took 1.0 seconds
Flake8 (linting) took 19.0 seconds
Pylint (linting) took 2.0 seconds
Ruff (formatting) took 0 seconds
Black (formatting) took 443.0 seconds
```

## Before running the benchmark

The benchmark script reinstalls Flake8, Black, Pylint, and Ruff to prevent caching. Then it reinstalls Ruff the second time because the script benchmarks Ruff again in formatting. This behavior may mess up your general Python collection of libraries, so I recommend running the benchmark in a virtual environment.

If you want to see its results when cached you need to install the tools first:
```bash
pip install flake8 pylint black ruff
```

Then, remove the `pip install` commands at lines 3 and 65.

Python doesn't make any cache until the tools have been used at least once so you won't see any performance improvement in the first run. You would start seeing performance changes from the second run onwards.

## Running the benchmark

To run the benchmark on your system, follow these steps:
1. Clone the repository to your system:
```bash
git clone https://github.com/GhoulKingR/ruff-benchmark.git
```
2. Open the `ruff-benchmark` folder in the terminal:
```bash
cd ruff-benchmark
```
3. Run the `benchmark.sh` script:
```bash
./benchmark.sh
```

If you get a "permission denied" error, you should make the script executable on your system. To do that run this command:
```bash
chmod +x benchmark.sh
```

## Benchmarking other codebases

By default, the benchmark script runs its tests on the scripts in the `scripts` folder. If you want to use the benchmark on a different codebase, follow these steps:
1. Place the codebase in the `ruff-benchmark` folder.
  * If you're using `git` clone the repository to the `ruff-benchmark` folder.
  * If the codebase is on your system locally, copy/move the codebase to the `ruff-benchmark` folder.
2. Open the `benchmark.sh` file in your IDE.
3. On line 5, change the value of `SCRIPT_FOLDER`from "./scripts" to the directory of your codebase preceded by `./`:
```bash
SCRIPT_FOLDER="./codebase_directory"
```
4. Save the file, and run the benchmark script in the terminal:
```bash
./benchmark.sh
```

## Adding a new tool to benchmark

If you want to add a new linter or code formatter to the benchmark you need to first make sure the tool is installed when the benchmark is running:
  * If you removed the `pip install` lines make sure to install the tool before running the benchmark script.
  * If you didn't remove the `pip install` lines, add the tool to the command on line 3. If you want to run more benchmarks, add a reinstallation line between benchmarks. An example is the `pip install` command on line 65.

Now, take a look at the benchmarks on lines 52 to 74 of the benchmark script. You may notice that every benchmark has this structure:
```bash
prepare_test_folder
benchmark_command "Ruff (linting)" "ruff check $TEST_FOLDER"  # benchmark command
rm -rf .ruff_cache/  # extra non-generic cleanup
cleanup_test_folder
```

When you want to add a new tool to a benchmark, its benchmark should follow that structure. Here's a breakdown:
1. Prepare the test folder
```bash
prepare_test_folder
```
2. Benchmark the tool with the scripts in the test folder (replace `command` with the command to call the tool):
```bash
benchmark_command "Label" "command $TEST_FOLDER"
```
3. Perform any extra cleanup outside just deleting the test folder (This step is optional. Not every tool needs you to do this)
4. Clean up the test folder
```bash
cleanup_test_folder
```

Here's a clear look at the format:
```bash
prepare_test_folder
benchmark_command "Label" "command $TEST_FOLDER"
cleanup_test_folder
```

You can place your edit anywhere in the script as long its after the `prepare_test_folder`, `cleanup_test_folder`, and `benchmark_command` definitions (lines 11 to 50).

After making your edits, save and run the script.
