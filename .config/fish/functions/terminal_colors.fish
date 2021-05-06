function terminal_colors --description "Print out all the terminal colors"
	for a in (seq 0 15)
		echo (tput setaf $a)color $a
	end
end
