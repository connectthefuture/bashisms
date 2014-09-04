mkdir -p $HOME/.bosh_cache

function bosh_keys() {
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