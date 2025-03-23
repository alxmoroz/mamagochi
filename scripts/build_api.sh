#!/usr/bin/env bash

services=(
  "mamagochi_api"
)

api_folder="./openapi"
cd "$api_folder" || exit

for service in ${services[@]}
do
  echo "Build $service"

  pub_name=${service//-/_}

  service_folder="$pub_name"
  cd "$service_folder"

  dart run build_runner build -d
  dart format ./**/*.dart

  cd ../
done

cd ../