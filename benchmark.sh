#!/bin/bash

pip install --force-reinstall flake8 pylint black ruff

SCRIPT_FOLDER="./scripts"
TEST_FOLDER="./test"
BENCHMARK_LOG="./benchmark.log"

> $BENCHMARK_LOG

prepare_test_folder() {
    mkdir -p $TEST_FOLDER
    cp -r $SCRIPT_FOLDER $TEST_FOLDER
    cat <<EOF >> "$TEST_FOLDER/.pylintrc"
[MASTER]
ignore=__pycache__,build,dist,.git
max-line-length=88

[FORMAT]
max-line-length=88
EOF
    cat <<EOF >> "$TEST_FOLDER/.flake8"
[flake8]
max-line-length = 88
exclude = .git,__pycache__,build,dist
EOF
    cat <<EOF >> "$TEST_FOLDER/ruff.toml"
line-length = 88
exclude = ["__pycache__", "build", "dist", ".git"]

[lint]
select = ["E", "F", "W"]
EOF
}

cleanup_test_folder() {
    rm -rf $TEST_FOLDER
}

benchmark_command() {
    local tool_name=$1
    local command=$2

    echo "Benchmarking $tool_name..."
    START_TIME=$(date +%s.%N)
    eval $command
    END_TIME=$(date +%s.%N)
    ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    echo "$tool_name took $ELAPSED_TIME seconds" | tee -a $BENCHMARK_LOG
}

prepare_test_folder
benchmark_command "Ruff (linting)" "ruff check $TEST_FOLDER"
rm -rf .ruff_cache/
cleanup_test_folder

prepare_test_folder
benchmark_command "Flake8 (linting)" "flake8 $TEST_FOLDER"
cleanup_test_folder

prepare_test_folder
benchmark_command "Pylint (linting)" "pylint $TEST_FOLDER/*.py"
cleanup_test_folder

pip install --force-reinstall ruff

prepare_test_folder
benchmark_command "Ruff (formatting)" "ruff format $TEST_FOLDER"
rm -rf .ruff_cache/
cleanup_test_folder

prepare_test_folder
benchmark_command "Black (formatting)" "black $TEST_FOLDER --check"
cleanup_test_folder

echo "Benchmark results:"
cat $BENCHMARK_LOG
