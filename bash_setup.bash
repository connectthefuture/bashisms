source /usr/local/share/chruby/chruby.sh
chruby ruby-1.9.3-p545

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
COLOR_NONE="\[\e[0m\]"

function parse_git_branch {
  git rev-parse --git-dir &> /dev/null
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is ([a-z]+)"
  diverge_pattern="# Your branch and (.*) have diverged"

  if [[ ! ${git_status}} =~ "working directory clean" ]]; then
    state="${RED}⚡ "
  fi
  # add an else if or two here if you want to get more specific
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="${YELLOW}↑"
    else
      remote="${YELLOW}↓"
    fi
  fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}↕"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo " (${branch})${remote}${state}"
  fi
}

function prompt_func() {
  previous_return_value=$?;

  history -a; # amend the session history to the history file so that new terminals have all the history of the other terminals

  prompt="${LIGHT_GRAY}\W${GREEN}$(parse_git_branch)${COLOR_NONE} "
  if test $previous_return_value -eq 0
    then
    PS1="${prompt}> "
  else
    PS1="${prompt}${RED}>${COLOR_NONE} "
  fi
}

export PROMPT_COMMAND=prompt_func
export GOPATH="/Users/onsi/go"
export PATH="$HOME/.bashisms/bin:$HOME/.bashisms/bosh_cache:$HOME/bin:$GOPATH/bin:/usr/local/opt/go/libexec/bin:$PATH"
export EDITOR='subl -w'
export GLIDER_URL=http://10.244.8.2.xip.io:5637

function goto {
  local p
  local f

  for p in `echo $GOPATH | tr ':' '\n'`; do
    f=`find ${p}/src -type d -not -path '*/.*' | grep "${1}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -n 1`
    if [ -n "$f" ]; then
      cd $f
      return
    fi
  done

  workto "$@"
}

function workto {
  local p
  local f

  f=`find ~/workspace -type d -not -path '*/.*' | grep "${1}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -n 1`
  if [ -n "$f" ]; then
    cd $f
    return
  fi
}

function each {
  for repo in *; do
    (
      echo -e "\x1B[32m$repo\x1B[0m"
      cd $repo
      eval $@
    )
  done
}

function each_status {
  each "git status --porcelain;git log --oneline @{u}.."
}

function each_ff {
  each "git pull --ff-only origin master && git submodule update --init --recursive"
}

