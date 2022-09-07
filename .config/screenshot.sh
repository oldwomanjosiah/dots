#!/bin/bash

case $1 in
	"select")
		fname=$(date +/home/josiah/screenshot/%Y-%m-%d_%H:%M:%S_selection.png)
		maim $fname -s
		xclip -selection c -t image/png < $fname
		;;
	*)
		fname=$(date +/home/josiah/screenshot/%Y-%m-%d_%H:%M:%S_full.png)
		maim $fname
		xclip -selection c -t image/png < $fname
		;;
esac

