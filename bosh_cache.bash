# vim: set ft=bash

mkdir -p $HOME/.bosh_cache

function current_bosh_cache() {
  echo -e "Currently targetting:  \x1B[32m`get_bosh_target`\x1B[0m | \x1B[32m`get_bosh_deployment`\x1B[0m"
  if [[ -n "$1" ]] ; then
    read -p "Is this correct? " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]];then
      return 1
    fi
  fi
}

function get_bosh_target() {
  cat $HOME/.bosh_cache/target
}

function get_bosh_deployment() {
  cat $HOME/.bosh_cache/deployment
}

function get_bosh_director() {
  cat $HOME/.bosh_cache/director
}

function bosh_ip () {
    if [[ -z "$1" ]] || [[ "$1" == "help" ]] ; then
      echo "usage: bosh_ip VM <deployment>"
      echo "returns the ip of the VM using the current deployment unless <deployment> is specified"
      return 1
    fi

    export VMS=''
    VMS=$1
    CURRENT_DEPLOYMENT=${2:-`get_bosh_deployment`}
    VMS_FILE="$HOME/.bosh_cache/${CURRENT_DEPLOYMENT}_vms"
    IP=`cat $VMS_FILE | ruby -ne 'a = /#{Regexp.escape(ENV["VMS"])}(?:.+?\|){3}(.+?)\|/.match($_); puts a[1].strip if a;'`
    if [[ `get_bosh_target` == "warden" ]]; then
      echo $IP.xip.io;
    else
      echo $IP;
    fi
}

function bosh_vms () {
  cat $HOME/.bosh_cache/*`get_bosh_target`*_vms
}

function bosh_keys () {
    if [[ ! -d $HOME/workspace/deployments-aws ]]; then
      echo "Please clone github.com/cloudfoundry/deployments-aws to $HOME/workspace/deployments-aws"
    fi

    if [[ ! -d $HOME/workspace/deployments-runtime ]]; then
      echo "Please clone github.com/pivotal-cf/deployments-runtime to $HOME/workspace/deployments-runtime"
    fi

    set | grep --color=auto -q SSH_AGENT_PID;
    if [[ ! $? -eq 0 ]]; then
        eval `ssh-agent`;
    fi;
    fgrep [localhost] $HOME/.ssh/known_hosts|
      awk '{print $1}' |
      while read bad_key ; do
        echo clearing $bad_key
        ssh-keygen -R  $bad_key > /dev/null 2>&1;
      done
    ssh-add $HOME/.ssh/id_rsa_bosh > /dev/null 2>&1;
    for i in a1 tabasco;
    do
        chmod 400 $HOME/workspace/deployments-aws/$i/config/id_rsa_bosh;
        ssh-add $HOME/workspace/deployments-aws/$i/config/id_rsa_bosh > /dev/null 2>&1;
    done;
    chmod 400 $HOME/workspace/deployments-runtime/ketchup/keypair/id_rsa_bosh;
    ssh-add $HOME/workspace/deployments-runtime/ketchup/keypair/id_rsa_bosh > /dev/null 2>&1;
}


function bosh_target () {
  if [[ -z "$1" ]] || [[ "$1" == "help" ]] ; then
    current_bosh_cache
    echo ""
    echo "usage: bosh_target TARGET (--refresh)"
    echo "Supports TARGET in { ketchup, tabasco, a1, warden }"
    echo "By default, this simply targets bosh.  Use --refresh to update the local cache."
    return;
  fi

  case "$1" in
    ketchup)
      echo "Targeting Ketchup"
      echo ketchup > $HOME/.bosh_cache/target
      echo micro.ketchup.cf-app.com > $HOME/.bosh_cache/director
      bosh target micro.ketchup.cf-app.com
      if [[ -n "$2" ]]; then
        mkdir -p $HOME/.bosh_cache/ketchup
        rm $HOME/.bosh_cache/ketchup/*
        echo "Fetching CF Manifest"
        bosh download manifest cf-ketchup $HOME/.bosh_cache/ketchup/cf.yml
        echo "Fetching Diego Manifest"
        bosh download manifest cf-ketchup-diego $HOME/.bosh_cache/ketchup/diego.yml
        echo "Fetching CF VMS"
        bosh vms cf-ketchup > $HOME/.bosh_cache/cf-ketchup_vms
        echo "Fetching Diego VMS"
        bosh vms cf-ketchup-diego > $HOME/.bosh_cache/cf-ketchup-diego_vms;
      else
        echo "NOT updating local cache.  Pass --refresh to do so";
      fi
      ;;
    tabasco)
      echo tabasco > $HOME/.bosh_cache/target
      echo bosh.tabasco.cf-app.com > $HOME/.bosh_cache/director
      bosh target bosh.tabasco.cf-app.com
      if [[ -n "$2" ]]; then
        mkdir -p $HOME/.bosh_cache/tabasco
        rm $HOME/.bosh_cache/tabasco/*
        echo "Fetching CF Manifest"
        bosh download manifest cf-tabasco $HOME/.bosh_cache/tabasco/cf.yml
        echo "Fetching Diego Manifest"
        bosh download manifest cf-tabasco-diego $HOME/.bosh_cache/tabasco/diego.yml
        echo "Fetching CF VMS"
        bosh vms cf-tabasco > $HOME/.bosh_cache/cf-tabasco_vms
        echo "Fetching Diego VMS"
        bosh vms cf-tabasco-diego > $HOME/.bosh_cache/cf-tabasco-diego_vms;
      else
        echo "NOT updating local cache.  Pass --refresh to do so";
      fi
      ;;
    a1)
      echo a1 > $HOME/.bosh_cache/target
      echo bosh.a1.cf-app.com > $HOME/.bosh_cache/director
      bosh target bosh.a1.cf-app.com
      if [[ -n "$2" ]]; then
        mkdir -p $HOME/.bosh_cache/a1
        rm $HOME/.bosh_cache/a1/*
        echo "Fetching CF Manifest"
        bosh download manifest cf-a1 $HOME/.bosh_cache/a1/cf.yml
        echo "Fetching Diego Manifest"
        bosh download manifest cf-a1-diego $HOME/.bosh_cache/a1/diego.yml
        echo "Fetching CF VMS"
        bosh vms cf-a1 > $HOME/.bosh_cache/cf-a1_vms
        echo "Fetching Diego VMS"
        bosh vms cf-a1-diego > $HOME/.bosh_cache/cf-a1-diego_vms;
      else
        echo "NOT updating local cache.  Pass --refresh to do so";
      fi
      ;;
    warden)
      echo warden > $HOME/.bosh_cache/target
      echo 192.168.50.4 > $HOME/.bosh_cache/director
      bosh target 192.168.50.4
      bosh login admin admin
      if [[ -n "$2" ]]; then
        mkdir -p $HOME/.bosh_cache/warden
        rm $HOME/.bosh_cache/warden/*
        echo "Fetching CF Manifest"
        bosh download manifest cf-warden $HOME/.bosh_cache/warden/cf.yml
        echo "Fetching Diego Manifest"
        bosh download manifest warden-diego $HOME/.bosh_cache/warden/diego.yml
        echo "Fetching CF VMS"
        bosh vms cf-warden > $HOME/.bosh_cache/cf-warden_vms
        echo "Fetching Diego VMS"
        bosh vms warden-diego > $HOME/.bosh_cache/warden-diego_vms;
      else
        echo "NOT updating local cache.  Pass --refresh to do so";
      fi
      ;;
    *)
      echo "Unkown target"
      return
  esac
}

function bosh_deployment () {
  if [[ -z "$1" ]] || [[ "$1" == "help" ]] ; then
    current_bosh_cache
    echo ""
    echo "usage: bosh_deployment DEPLOYMENT"
    echo "Supports DEPLOYMENT in { diego, cf }"
    return;
  fi

  case "$1" in
    cf)
      echo "Setting deployment to CF.  Current target: `get_bosh_target`"
      bosh deployment $HOME/.bosh_cache/`get_bosh_target`/cf.yml
      echo cf-`get_bosh_target` > $HOME/.bosh_cache/deployment;
      ;;
    diego)
      echo "Setting deployment to Diego.  Current target: `get_bosh_target`"
      bosh deployment $HOME/.bosh_cache/`get_bosh_target`/diego.yml
      if [[ `get_bosh_target` == "warden" ]]; then
          echo warden-diego > $HOME/.bosh_cache/deployment;
        else
          echo cf-`get_bosh_target`-diego > $HOME/.bosh_cache/deployment;
      fi
      ;;
    *)
      echo "Unkown deployment"
      return
  esac
}

function bosh_ssh () {
    if [[ -z "$1" ]] ; then
      echo "usage: bosh_ssh VM_NAME"
      return;
    fi

    if ! current_bosh_cache --prompt ; then
      return;
    fi

    if [[ `get_bosh_target` == "warden" ]]; then
      if ! which sshpass > /dev/null ; then
        echo "Please install sshpas"
        echo "brew install https://raw.github.com/eugeneoden/homebrew/eca9de1/Library/Formula/sshpass.rb"
        return 1
      fi
      IP=`bosh_ip $1`
      echo "ssh vcap@$IP"
      sshpass -p c1oudc0w ssh -o StrictHostKeyChecking=no vcap@$IP #password??
    else
      bosh_keys
      DIRECTOR_ADDRESS=`get_bosh_director`
      echo "bosh ssh $1 --gateway_host $DIRECTOR_ADDRESS --gateway_user vcap"
      bosh ssh $1 --gateway_host $DIRECTOR_ADDRESS --gateway_user vcap;
    fi
}

function bosh_download () {
    if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
      echo "usage: bosh_download VM_NAME REMOTE_SOURCE LOCAL_DESTINATION"
      echo "LOCAL_DESTINATION is always a folder"
      return;
    fi

    if [[ ! -d $3 ]]; then
      if ! mkdir -p $3; then
        echo "$3 must be a folder"
        return;
      fi
    fi

    if ! current_bosh_cache --prompt ; then
      return;
    fi

    if [[ `get_bosh_target` == "warden" ]]; then
      IP=`bosh_ip $1`
      echo "scp vcap@$IP:$2 $3"
      scp -o StrictHostKeyChecking=no vcap@$IP:$2 $3
    else
      bosh_keys
      DIRECTOR_ADDRESS=`get_bosh_director`
      echo "bosh scp $1 --download --gateway_host $DIRECTOR_ADDRESS --gateway_user vcap $2 $3"
      bosh scp $1 --download --gateway_host $DIRECTOR_ADDRESS --gateway_user vcap $2 $3
    fi
}

function bosh_tunnel () {
  return 1
  if ! current_bosh_cache --prompt ; then
    return;
  fi
  bosh_keys
  LOCAL_PORT=$1
  VMS=$2
  REMOTE_PORT=$3
  VMS_ADDRESS=`bosh_ip $VMS`
  DIRECTOR_ADDRESS=`get_bosh_director`
  echo "ssh -o StrictHostKeyChecking=no -o BatchMode=yes -f -N -L $LOCAL_PORT:$VMS_ADDRESS:$REMOTE_PORT vcap@$DIRECTOR_ADDRESS"
  ssh -o StrictHostKeyChecking=no -o BatchMode=yes -f -N -L $LOCAL_PORT:$VMS_ADDRESS:$REMOTE_PORT vcap@$DIRECTOR_ADDRESS
}
