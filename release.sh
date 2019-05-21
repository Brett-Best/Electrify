#!/bin/bash

set -e

git pull
./build.sh
./deploy.sh $1
