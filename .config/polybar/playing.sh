#!/bin/bash

if playerctl --player=spotify,chromium status | grep -q "Paused"; then
	echo ""
else
	echo ""
fi
