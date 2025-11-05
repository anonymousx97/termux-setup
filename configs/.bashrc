shopt -s cdspell      # cd with spelling mistakes ex: cd xzy will cd to xyz if dir exists
shopt -s autocd       # just typing xyz will cd to it automatically [if exists] [is spelling sensitive] [supports globbing]
shopt -s globstar     # turn on recursive globbing ex **/*.txt will find txt files recursively
shopt -s nullglob     # globbing expands to empty string when it fails to match things.
shopt -s extglob      # enables regex based globbing pattern support.
shopt -s checkwinsize # checks window sizes (lines, columns) on resize/launch.

# Useful aliases
alias cds="cd /sdcard"
alias cdd="cd /sdcard/Download"

alias q="exit"
alias clr="clear && rxfetch"
alias la="ls -a"

alias apti="apt install"
alias aptu="apt update -y && apt upgrade"
alias aptr="apt remove"

alias pipi="pip install"
alias pipu="pip install -U"
alias pipr="pip uninstall -y"

alias py="python"
alias pym="python -m"

alias gc="git clone"
alias gp="git push"
alias ga="git add --all"
alias gcm="git commit -m"
alias gs="git status"
alias gd="git diff --diff-filter=ACMRTUXB"
alias gl='git log --all --graph --oneline --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n"'

function cd() {
	# auto runs ls after cd'ing to a dir.
	builtin cd "$@" && ls
}

function prt() {
	# runs ruff tool on given file/dir
	ruff check --fix "$@"
	ruff format "$@"
}

function shh() {
	# Quietly run a command
	"$@" >/dev/null 2>&1
}
