#!/usr/bin/env bash

set -e
set -x

bash ./scripts/generate_api.sh $1

flutter clean
flutter pub get

bash ./scripts/build_api.sh

flutter pub global activate intl_utils
dart run intl_utils:generate

dart run build_runner build -d
