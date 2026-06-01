#! /usr/bin/env bash
IMAGE="$1"

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <path-to-image>"
  exit 1
fi

awww img "$IMAGE" --transition-type wipe

matugen image "$IMAGE" -m dark -t scheme-tonal-spot --source-color-index 0
