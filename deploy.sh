#!/bin/sh

INTENT="org.love2d.android/.GameActivity"

#remove old love
rm ./game.love

# zip the files
zip -r game.love ./

# copy the files
cp game.love ~/repos/love-android-sdl2/assets


