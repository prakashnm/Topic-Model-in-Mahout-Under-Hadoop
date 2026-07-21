#!/usr/bin/env bash
# Compile the three standalone Java programs into ./out/.
# They use only the JDK standard library (verified with OpenJDK 11), so no
# Mahout/Hadoop jars are needed just to compile. A clean compile is the
# fastest correctness check in this repo — run it after editing any .java file.
#
# Run a program with its fully qualified name, e.g.:
#   java -cp out org.mahout.assignment5.DocumentGenerator
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p out
javac -d out ./*.java
echo "Compiled to ./out/"
