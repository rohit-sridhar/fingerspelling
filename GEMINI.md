### Build, test, and lint commands

- Docker image (build):
    ./scripts/run_docker.sh build

- Launch a runnable container (mounts host paths):
    ./scripts/run_docker.sh launch <CONTAINER_NAME> <PROJECTS_ROOT>
    Environment vars that affect mounts and runtime: LOCAL_HTK_IMAGE, PROJECTS_ROOT, CONTINUOUS_BIGRAM_PATH, FS_TRANSFORMERS_PATH, FINGERSPELLING_VIDEO_PATH, ISLR_MPUTILS_OUT_PATH, VIMRC_FILE

- Run a script inside the container (detached):
    ./scripts/run_docker.sh run <CONTAINER_NAME> <script_relative_path> [PROJECTS_ROOT]

- Simple unit-test helper (container-based):
    ./scripts/run_docker_unit_test.sh

- Pytest (locally or inside container):
    run entire tests under ContinuousBigram/scripts/tests
    pytest -q ContinuousBigram/scripts/tests

    run a single test function
    pytest -q ContinuousBigram/scripts/tests/test_grid_search.py::test_get_ip_ext

- Linting
    Shell scripts (recommended):
    shellcheck scripts/*.sh

    Python style recommended by CONTRIBUTING (not enforced here): run black/flake8 where applicable

### High-level architecture (big picture)

- Purpose: HMM-based fingerspelling modeling and training pipelines live primarily under ContinuousBigram/.
    - ContinuousBigram/scripts: main orchestration and helper scripts for preparing data, running grid searches, and postprocessing.
    - ContinuousBigram/hmmdefs: precomputed HMM definitions and model files referenced by training/testing scripts.
    - ContinuousBigram/{models,output,logs,...}: runtime artifacts; many are created by scripts/prep_for_training.sh and by training runs.

- Execution model:
    - Development and runtime are expected inside a Docker image (see Dockerfile). The Docker workflow mounts host datasets and other project roots into predictable container paths.
    - Data and labels are NOT checked into the repo; mount or provide paths via the run_docker.sh environment variables.

### Key conventions and patterns

- Shell scripts
    - All repo shell scripts use `set -euo pipefail` and should pass shellcheck. Follow existing patterns in scripts/\*.sh.
    - Use 4 spaces for indentation.
    - Use the shell script template in ~/.vim/shell_header.txt (lines 2 - 10).
    - Decompose any lines of code used more than once into callable functions.
    - All error messages should go to STDERR.
    - Add the file name to line 4, the current date to line 5 and a file description after line 9.
    - All functions should be preceded by a comment describing the function's input, output, globals used and a description of what the function does.
    - Don't indent nes used and a description of what the function does.
    - Don't indent nested loops, but do indent nested if statements.
    - Split any lines of code longer than 80 lines into multiple lines.
    - Use variable expansion always (${var} instead of $var)
    - Follow the style guide here (https://google.github.io/styleguide/shellguide.html) otherwise (except for indentation: use 4 spaces always)

- Python scripts
    - Use 4 spaces for indenting
    - Name functions in all lowercase with words separated by underscores
    - Only import the necessary packages (avoid import \*)
    - Use ~/.vim/python_header.txt for new python files as the template

- Docker-first workflow
    - Scripts are written to run inside a prepared Docker image (rohitsridhar91/asl_sign_recognizer or LOCAL_HTK_IMAGE). Use scripts/run_docker.sh to build/launch/run.

- Tests
    - Tests live under ContinuousBigram/scripts/tests and use pytest. They may modify sys.path to import the scripts package (tests expect the scripts/ folder to be importable).
    - To run a single test, use pytest path::test_name as shown above.
    - Some tests monkeypatch filesystem helpers (e.g., override gs.make_dir); be aware when changing helper functions.

- Model naming conventions
    - Model filenames and experiment names encode tokens such as trace numbers and hyperparameters. Examples from tests and code:
        - trace suffixes like .TR3
    - When updating model naming or parsing logic, update functions that generate/get these tokens (e.g., grid_search helpers).

- Repo-level workflow and commits
    - Follow CONTRIBUTING.md: create small branches, include the Co-authored-by trailer in assistant-made commits:

- Project skeleton
    - Use ./scripts/prep_for_training.sh [ROOT] to create the ContinuousBigram directory skeleton (models, data, output, logs, etc.).

Files and locations to check quickly

- ContinuousBigram/scripts - primary scripts and grid search logic
- ContinuousBigram/hmmdefs - HMM definitions used by experiments
- scripts/run_docker.sh - Docker build/run/launch helper and env var usage
- scripts/run_docker_unit_test.sh - example unit-test flow that runs a short container job

Notes for Gemini sessions

- Prefer Docker-based commands for reproducibility. If a change affects runtime behavior, run the relevant scripts inside the container to validate.
- When editing scripts, run shellcheck and the unit test helper before pushing changes.
- Tests assume importability of the scripts package; keep module-level side-effects minimal and predictable.

References

- README.md and CONTRIBUTING.md contain more detailed usage and commit guidelines.

