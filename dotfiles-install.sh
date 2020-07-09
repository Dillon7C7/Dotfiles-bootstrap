#!/usr/bin/dash

script_bname="${0##*/}"
repo_url="https://github.com/Dillon7c7/Dotfiles"

dotgit_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/dotfiles.git"
dotgit_temp="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles-temp"

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

# make sure git is installed
if ! command -v /usr/bin/git 2>&1 >/dev/null; then
	_error_and_exit "/usr/bin/git not found!"
fi

# make sure the files we will use don't already exist
[ ! -e "$dotgit_dir" ] || _error_and_exit "$dotgit_dir already exists! Either rename it, or edit the script."
[ ! -e "$dotgit_temp" ] || _error_and_exit "$dotgit_temp already exists! Either rename it, or edit the script."

# clone git repo!
/usr/bin/git clone --separate-git-dir="$dotgit_dir" "$repo_url" "$dotgit_temp"
[ $? -eq 0 ] || _error_and_exit "git clone failed. Check your internet connection."

# $XDG* are exported in .profile, however that hasn't been sourced yet, so we export it here
## this prevents the dotgit alias in ~/.bash_aliases from breaking
export XDG_CONFIG_HOME="$HOME/.config"

# move files from temp dir to $HOME and rm the temp dir
cp -rTv "$dotgit_temp" ~ && rm -rfv "$dotgit_temp" && . ~/.bash_aliases || _error_and_exit "Error cping or rming files!"

dotgit config status.showUntrackedFiles no
[ $? -eq 0 ] && _print_success "Dotfiles installed!" || _error_and_exit "Something broke! Perhaps check ~/.bash_aliases"

printf '%b\n' "$(tput setaf 5)Deleting this script now...$(tput sgr0)"
exec rm -vf "$0"
