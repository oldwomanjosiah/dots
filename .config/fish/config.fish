abbr -a vim 'nvim'

abbr -a pip 'pip3'
abbr -a python 'python3'

abbr -a status 'git status'
abbr -a fetch 'git fetch'
abbr -a glog 'git log --graph --pretty=format:\'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset\' --abbrev-commit --date=relative --branches'

abbr -a watchtree 'watch -c \'tree -C -L 3\''

abbr -a fvim 'nvim (fzf-tmux -r)'

abbr -a exa 'exa -hl --git --group-directories-first'
abbr -a exatree 'exa -hTl -L 4 --git --group-directories-first'

abbr -a ls 'exa -hl --git --group-directories-first'
abbr -a la 'exa -hla --git --group-directories-first'

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set __fish_git_prompt_showupstream 'verbose'

set -g fish_prompt_pwd_dir_length 3

# fzf.fish options
# set --export FZF_DEFAULT_OPTS --height 50% --margin 1

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (hostname)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color blue
	printf '%s ' (__fish_git_prompt)
	if [ ! $status ]
		set_color red
	else
		set_color green
	end
	echo -n '> '
	set_color normal
end

function startup
	ssh-add ~/.ssh/uwm_ale &> /dev/null
end

function is_tmux
	set -q TMUX
end

function fish_greeting
	if is_tmux; else
		# Print system information
		neofetch


		if tmux ls &> /dev/null
			set_color -uo green
			echo === Open Tmux Sessions ===
			set_color normal
			# tmux ls
			# /Very special/ printing method
			echo "   name"\t"created"\t"windows"\n(tmux ls | sed -rn "s/(.+): ([[:digit:]]+) windows \(created ([[:alpha:]]+) ([[:alpha:]]+ [[:digit:]]+) ([[:digit:]]{2}:[[:digit:]]{2}):[[:digit:]]{2} [[:digit:]]{4}\)/-> \1\t\5 on \3 [\4]\t\2 Windows/p" | tr '\n' '\f')\
				| tr '\f' '\n' | column -s=\t -t
		else
			set_color -uo red
			echo === No Tmux Sessions Open ===
			set_color normal
		end
	end
end

function config
	/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end

function op-signin
	eval (op signin my)
end

set -U GEM_HOME '~/.gem'
set -U GEM_PATH '~/.gem'

[ -t 1 ]; and startup
export GPG_TTY=(tty)

starship init fish | source

function swim
	sudo
end
