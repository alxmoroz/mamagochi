#!/usr/bin/env bash

STAGE="test"
if [[ -n $1 ]]; then
  STAGE="$1"
fi

services=(
  "mamagochi_api"
)

api_folder="./openapi"

fullDir="${PWD}/${api_folder}"
rm -rf "$fullDir"
mkdir "$fullDir"
cd "$api_folder" || exit

for service in ${services[@]}
do
  echo "Generate client service from $service"

  pub_name=${service//-/_}

  service_folder="./$pub_name"
  rm -rf "$service_folder"
  mkdir "$service_folder"
  cd "$service_folder" || exit

  remote_schema="https://$STAGE.mamagochi.ru/api/v1/openapi.json"
#  remote_schema="http://127.0.0.1:9999/api/v1/openapi.json"

  curl -L $remote_schema > openapi.json

  #openapi-generator-cli generate -i openapi.json -g dart-dio -o .

  java -ea                          \
    ${JAVA_OPTS}                    \
    -Xms512M                        \
    -Xmx1024M                       \
    -server                         \
    -jar ../../scripts/openapi-generator-cli.jar generate \
    --skip-validate-spec \
    --global-property modelTests=false,apiTests=false \
    -p pubName=$pub_name \
    -i openapi.json \
    -g dart-dio -o .

  cd ../
done

cd ../