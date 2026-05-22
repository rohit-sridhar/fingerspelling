#!/usr/bin/env bash
set -euo pipefail

# Simple unit test: run the container detached and verify it prints ECHO_TEST_OK
TEST_SCRIPT="./scripts/tests/echo_test.sh"
CONTAINER_NAME="fs_hmm"
EXPECTED="ECHO_TEST_OK"

echo "Running: ./scripts/run_docker.sh run $CONTAINER_NAME $TEST_SCRIPT"
CID=$(./scripts/run_docker.sh run "$CONTAINER_NAME" "$TEST_SCRIPT")
echo "Container ID after calling the test script: ${CID}"

# If run_docker.sh prints container id, capture it; otherwise, try to use container name
if [ -z "$CID" ]; then
  # try to get container id by name (may be running)
    CID=$(docker ps -aqf "name=^/${CONTAINER_NAME}$" || true)
    echo "Container ID after calling the test script: ${CID}"
fi

if [ -z "$CID" ]; then
    echo "Failed to get container id"
    exit 2
fi

# Wait for container to exit (max ~10s), then fetch logs
for i in {1..20}; do
    STATUS=$(docker inspect -f '{{.State.Running}}' "$CID" 2>/dev/null || echo "false")
    if [ "$STATUS" != "true" ]; then
        break
    fi
    sleep 0.5
done

# Get logs
LOGS=$(docker logs "$CID" 2>/dev/null || true)
echo "Container logs:"
echo "$LOGS"

# cleanup container if still exists
docker rm -f "$CID" >/dev/null 2>&1 || true

if echo "$LOGS" | grep -q "$EXPECTED"; then
    echo "TEST PASSED"
    exit 0
else
    echo "TEST FAILED: expected '$EXPECTED' in logs"
    exit 1
fi
