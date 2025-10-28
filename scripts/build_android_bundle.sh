#!/usr/bin/env bash

# Copyright (c) 2022. Alexandr Moroz

echo "BUILDING FOR ANDROID..."

flutter build appbundle \
  --release \
  --shrink \
  --split-debug-info=build/app/outputs/symbols

echo "BUILDING FOR ANDROID COMPLETE"
