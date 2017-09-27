#              _                 _
#   __ _  __ _| | _____ ______ _| | __
#  / _` |/ _` | |/ / _ \_  / _` | |/ /
# | (_| | (_| |   < (_) / / (_| |   <
#  \__,_|\__, |_|\_\___/___\__,_|_|\_\
  #        |___/
#
# A dynamic color prompt for zsh with Git, vi mode, and exit status indicators
#
# Copyright (C) 2017 Alexandros Kozák
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
#
# https://github.com/agkozak/agkozak-zsh-theme
#

# $psvar[] Usage
#
# $psvar Index  Prompt String Equivalent    Usage
#
# $psvar[1]     %1v                         Hostname/abbreviated hostname (only
#                                           displayed for SSH connections)
# $psvar[2]     %2v                         Working directory or abbreviation
#                                           thereof
# $psvar[3]     %3v                         Current working Git branch, along
#                                           with indicator of changes made

setopt PROMPT_SUBST

_is_ssh() {
if [[ -n $SSH_CLIENT ]] || [[ -n $SSH_TTY ]]; then
  true
else
  case "$EUID" in
    0)
      case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) true ;;
      esac
      ;;
    *) false;
  esac
fi
}

_haz_colors=$(tput colors)

# Display current branch and status
_branch_status() {
local ref branch
ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
case $? in        # See what the exit code is.
  0) ;;           # $ref contains the name of a checked-out branch.
  128) return ;;  # No Git repository here.
  # Otherwise, see if HEAD is in detached state.
  *) ref=$(git rev-parse --short HEAD 2> /dev/null) || return ;;
esac
branch=${ref#refs/heads/}
printf ' (%s%s)' "$branch" "$(_branch_changes)"
}

# Display symbols representing the current branch's status
_branch_changes() {
local git_status symbols

git_status=$(command git status 2>&1)

# $messages is an associative array whose keys are text to be looked for in
# $git_status and whose values are symbols used in the prompt to represent
# changes to the working branch
declare -A messages

messages=(
'renamed:'                '>'
'Your branch is ahead of' '*'
'new file:'               '+'
'Untracked files'         '?'
'deleted'                 'x'
'modified:'               '!'
)

for k in ${(@k)messages}; do
  case "$git_status" in
    *${k}*) symbols="${messages[$k]}${symbols}" ;;
  esac
done

[[ ! -z "$symbols" ]] && printf '%s' " $symbols"
}

# precmd() runs before each prompt is drawn
#
# Emulate bash's PROMPT_DIRTRIM behavior by prepending `~` before
# abbreviated paths in the $HOME directory
#
# Calculate working Git branch and branch status
precmd() {
  case "$PWD" in
    $HOME*)
      psvar[2]=$(print -P "%(4~|.../%2~|%~)")
      case ${psvar[2]} in
        '.../'*)
          psvar[2]=$(printf '~/%s' "${psvar[2]}")
          ;;
      esac
      ;;
    *) psvar[2]=$(print -P "%(3~|.../%2~|%~)") ;;
  esac
  psvar[3]=$(_branch_status)
}

# When the user enters vi command mode, the % or # in the prompt changes into
# a colon
_vi_mode_indicator() {
  case "$KEYMAP" in
    vicmd) printf '%s' ':' ;;
    *) printf '%s' '%#' ;;
  esac
}

# Redraw prompt when vi mode changes
zle-keymap-select() {
  zle reset-prompt
  zle -R
}

# Redraw prompt when terminal size changes
TRAPWINCH() {
  zle && zle -R
}

zle -N zle-keymap-select

if _is_ssh; then
  psvar[1]="$(print -P "@%m")"
else
  psvar[1]=''
fi

if [[ $_haz_colors -ge 8 ]]; then
  # Autoload zsh colors module if it hasn't been autoloaded already
  if ! whence -w colors > /dev/null 2>&1; then
    autoload -Uz colors
    colors
  fi

  PS1='%{$fg_bold[green]%}%n%1v%{$reset_color%} %{$fg_bold[blue]%}%2v%{$reset_color%}%{$fg[yellow]%}%3v%{$reset_color%} $(_vi_mode_indicator) '
  # PS1='%{$fg_bold[blue]%}%2v%{$reset_color%}%{$fg[yellow]%}%3v%{$reset_color%} $(_vi_mode_indicator) '

  # The right prompt will show the exit code if it is not zero.
  RPS1="%(?..%{$fg_bold[red]%}(%?%)%{$reset_color%})"
else
  PS1='%n%1v %2v%3v $(_vi_mode_indicator) '
  RPS1="%(?..(%?%))"
fi

# vim: tabstop=4 expandtab:
