#!/bin/sh

INTENT="org.love2d.android/.GameActivity"

# zip the files
zip -r game.love ./

# copy the files
adb push ./game.love /sdcard/

# restart the application
adb shell am start -S -n $INTENT -d file:///sdcard/game.love
