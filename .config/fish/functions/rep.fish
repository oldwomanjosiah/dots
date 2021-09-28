function rep
	begin
		rg --color always --heading $argv
		rg --count-matches $argv |\
			awk -F ':' '{ sum += $2 } END { print "Total Matches " sum }'
	end | less -r
end
