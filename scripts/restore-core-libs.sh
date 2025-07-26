#!/bin/bash

set -e

mkdir -p Sources/Resources Tests/Resources

cp core-libs/* Sources/Resources/
cp core-libs/* Tests/Resources/

rm -rd core-libs
