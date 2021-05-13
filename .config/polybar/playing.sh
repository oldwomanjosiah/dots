#!/bin/bash

if playerctl --player=spotify status | grep -q "Paused"; then
	echo ""
else
	echo ""
fi
