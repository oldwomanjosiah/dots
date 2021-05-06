#!/bin/sh

stalonetray &&\
	sleep 1 &&\
	xdotool windowunmap $(xdotool search --class stalonetray)

