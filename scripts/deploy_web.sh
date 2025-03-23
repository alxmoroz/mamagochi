#!/usr/bin/env bash

# Copyright (c) 2022. Alexandr Moroz

echo "DEPLOYING WEB..."
cp -r ./build/web/* /var/www/mamagochi/
echo "DEPLOYING WEB COMPLETE"
