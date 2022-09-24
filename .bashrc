function ls() {
	/usr/bin/exa -hl --git --group-directories-first "$@"
}

function la() {
	/usr/bin/exa -hla --git --group-directories-first "$@"
}

function lq() {
	/usr/bin/exa "$@"
}

function dit() {
	git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME "$@"
}

export GPG_TTY=$(tty)
export PATH=$HOME/.cargo/bin/:$PATH
export EDITOR=nvim
