#!/bin/bash

set -e

git pull
./build.sh
./release.sh
