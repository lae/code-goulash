#!/bin/bash -fue
set -- $SSH_ORIGINAL_COMMAND # passes the SSH command to ARGV
up='/home/lae/milk.tea.jp/p/'
img='/home/lae/milk.tea.jp/i/'
tmp='/home/lae/milk.tea.jp/tmp/'
function error() {
  if [ -z "$*" ]; then details="request not permitted"; else details="$*"; fi
  echo -e "ERROR: $details"
  exit
}
#error "$SSH_CONNECTION"
if [ "$1"  != 'scp' ]; then error; fi # checks to see if remote is using scp
if [ "$2" != "-t" ]; then error; fi # checks flags for local scp to retrieve a file
shift
shift
if [[ "$@" == '.' ]]; then error "destination not specified"; fi # checks that the command isn't scp -t .
if [[ "$@" == ../* ]] || [[ "$@" == ./* ]] || [[ "$@" == /* ]] || [[ "$@" == */* ]] || [[ "$@" == .. ]]; then
  error "destination traverses directories"
fi
dest=$up$@
if [ x${dest##*.} == xtmp ]; then
  dest=$tmp$@
  dest=${dest%.tmp}
elif [ x${dest##*.} == xpng ] || [ x${dest##*.} == xjpg ]; then
  dest=$img$@
fi
if [[ -f "$dest" ]]; then error "file exists on server"; fi
exec scp -t "$dest"
# I'm not specifying $@ here as it seems to exec without the quotation marks, 
# which causes the 'ambiguous target' error in scp.
# the sanity checks above appear to work, though.
