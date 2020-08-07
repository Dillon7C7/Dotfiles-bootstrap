#!/bin/sh

script_bname="${0##*/}"
repo_url="https://github.com/Dillon7c7/Dotfiles"

config_home="${HOME}/.config"
cache_home="${HOME}/.cache"

dotgit_dir="${config_home}/dotfiles.git"
dotgit_temp="${cache_home}/dotfiles-temp"

# print success message to stdin
_print_success()
{
	msg="$1"
	printf '%b\n' "$(tput setaf 3)SUCCESS ${script_bname}: $(tput setaf 2)${msg}$(tput sgr0)"
}

# print error message to stderr (with colors!!), and exit
_error_and_exit()
{
	error_msg="$1"
	printf '%b\n' "$(tput setaf 3)ERROR ${script_bname}: $(tput setaf 1)${error_msg}$(tput sgr0)" >&2
	exit 1
}

# handle unexpected signals
handle_signals()
{
	printf '%b\n' "$(tput setaf 3)Trap caught! Removing ${dotgit_dir} and ${dotgit_temp}$(tput sgr0)"
	rm -rfv "$dotgit_dir"
	rm -rfv "$dotgit_temp"
	exit 2
}

# make sure git is installed
if ! command -v /usr/bin/git >/dev/null 2>&1; then
	_error_and_exit "/usr/bin/git not found!"
fi

# make sure the directories we will use don't already exist
[ ! -e "$dotgit_dir" ] || _error_and_exit "$dotgit_dir already exists! Either rename it, or edit the script."
[ ! -e "$dotgit_temp" ] || _error_and_exit "$dotgit_temp already exists! Either rename it, or edit the script."

# the trap is placed AFTER the dir checking; we wouldn't want to remove a previously existing dir!
trap 'handle_signals' HUP INT QUIT TERM

mkdir -p "$config_home" "$cache_home"

# clone git repo!
if ! /usr/bin/git clone --separate-git-dir="$dotgit_dir" "$repo_url" "$dotgit_temp"; then
	_error_and_exit "git clone failed. Check your internet connection, and also make sure git is installed."
fi

# move files from temp dir to $HOME and rm the temp dir
cp -rTv "$dotgit_temp" ~ && rm -rfv "$dotgit_temp" && . ~/.profile || _error_and_exit "Error cping or rming files!"

if dotgit config status.showUntrackedFiles no >/dev/null 2>&1; then
	_print_success "Dotfiles installed!"
else
	_error_and_exit "Something broke! Perhaps check ~/.bash_aliases"
fi

printf '%b\n' "$(tput setaf 5)Deleting this script now...$(tput sgr0)"
exec rm -vf "$0"
