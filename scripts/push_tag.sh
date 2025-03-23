#!/usr/bin/env bash

# Copyright (c) 2022. Alexandr Moroz

set -e
set -x

build_number=$(git rev-list --all | wc -l | xargs)
sed -i.bak "s/^\(version:.*[.]\).*$/\1$build_number+$build_number/" pubspec.yaml

version=$(grep 'version: ' pubspec.yaml | sed "s/^[^0-9]*\(.*[.]\).*/\1$build_number/")

bash ./scripts/build_full.sh
bash ./scripts/build_web.sh

git commit -a -m "Bump version to $version"

git tag "$version"
git push

echo "Bump version to $version to git"