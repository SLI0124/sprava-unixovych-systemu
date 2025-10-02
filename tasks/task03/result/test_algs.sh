#!/bin/bash
# Test multiple checksum algorithms with module parameters

MOD_NAME="my_checksum_dev"
MOD_FILE="./my_checksum_dev.ko"
TEST_FILE="test.txt"
DEV_FILE="/dev/checksum"

# Make sure we have a test file
echo "Hello, World!" > "$TEST_FILE"

# List of algorithms and levels to test
ALGORITHMS=("md5" "sha1" "sha256" "sha512" "xor")
LEVELS=(1 32 64 128)

for algo in "${ALGORITHMS[@]}"; do
    for lvl in "${LEVELS[@]}"; do
        echo "============================================"
        echo " Testing algorithm=$algo, level=$lvl"
        echo "--------------------------------------------"

        # remove module if already loaded
        if lsmod | grep -q "$MOD_NAME"; then
            rmmod $MOD_NAME
            sleep 1
        fi

        # insert module
        insmod $MOD_FILE algorithm=$algo level=$lvl || {
            echo "Failed to load $algo:$lvl"
            continue
        }
        sleep 1

        # feed data
        cat "$TEST_FILE" > "$DEV_FILE"

        # read result
        echo -n "Result: "
        cat "$DEV_FILE"

        # show last kernel log
        dmesg | tail -n 3

        echo
        sleep 1
    done
done

# cleanup
rmmod $MOD_NAME
