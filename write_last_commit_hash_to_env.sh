#!/bin/bash

LAST_COMMIT_HASH=$(git rev-parse HEAD)
sed -i "s/^LAST_COMMIT_HASH=.*/LAST_COMMIT_HASH=$LAST_COMMIT_HASH/" .env
