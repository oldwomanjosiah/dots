#!/bin/bash

function get_pointer {
	xinput list |\
		grep -iE slave |\
		grep -iE pointer |\
		grep -iE "(Touch|Mouse|Track)" |\
		grep -iEv Keyboard |\
		sed -nr 's/.+id=([0-9]+).+/\1/p'
}

# Arg1: pointer id
function get_natural_scrolling_prop {
	xinput list-props $1 |\
		grep -iE Natural |\
		grep -iE Scrolling |\
		grep -iEv Default |\
		sed -nr 's/.+\(([0-9]+)\).+/\1/p'
}

# Arg1: pointer id
# Arg2: prop to enable
function set_prop {
	xinput set-prop $1 $2 1
}

function set_invert {
	local pointer="$1"
	local prop="$(get_natural_scrolling_prop $pointer)"

	set_prop $pointer $prop

	if [[ $? ]]; then
		echo Natural scrolling enabled for pointer $pointer \(prop $prop\)
	else
		echo Natural scrolling failed to enable
	fi
}

for pointer in $(get_pointer); do
	set_invert "$pointer"
done


