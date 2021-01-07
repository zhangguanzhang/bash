set -o errexit    # abort script at first error
# set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

err() {
  printf '%b\n' ""
  printf '%b\n' "\033[1;31m[ERROR] $@\033[0m"
  printf '%b\n' ""
  exit 1
} >&2

success() {
  printf '%b\n' ""
  printf '%b\n' "\033[1;32m[SUCCESS] $@\033[0m"
  printf '%b\n' ""
}

extract() {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

# https://stackoverflow.com/questions/26621647/convert-human-readable-to-bytes-in-bash
dehumanise() {
  numfmt --from=iec $@
#   for v in "${@:-$(</dev/stdin)}"
#   do  
#     echo $v | awk \
#       'BEGIN{IGNORECASE = 1}
#        function printpower(n,b,p) {printf "%u\n", n*b^p; next}
#        /[0-9]$/{print $1;next};
#        /K(iB)?$/{printpower($1,  2, 10)};
#        /M(iB)?$/{printpower($1,  2, 20)};
#        /G(iB)?$/{printpower($1,  2, 30)};
#        /T(iB)?$/{printpower($1,  2, 40)};
#        /KB$/{    printpower($1, 10,  3)};
#        /MB$/{    printpower($1, 10,  6)};
#        /GB$/{    printpower($1, 10,  9)};
#        /TB$/{    printpower($1, 10, 12)}'
#   done
} 
