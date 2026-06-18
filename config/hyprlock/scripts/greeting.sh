#! /usr/bin/env bash

hour=$(date +%H)

if [ "$hour" -ge 5 ] && [ "$hour" -lt 12 ]; then
  greeting="Good Morning :)"
elif [ "$hour" -ge 12 ] && [ "$hour" -lt 17 ]; then
  greeting="Good Afternoon :)"
elif [ "$hour" -ge 17 ] && [ "$hour" -lt 21 ]; then
  greeting="Good Evening :)"
elif [ "$hour" -ge 21 ] && [ "$hour" -lt 24 ]; then
  greeting="Good Night :)"
else
  greeting="GO TO SLEEP!"
fi

echo -e "Hello, $USER! $greeting"
