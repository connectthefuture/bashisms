function veritas_envs() {
  if [[ `get_bosh_deployment` != "warden-diego" ]] ; then
    echo "You must use bosh cache and set the target to 'warden' and the deployment to 'diego'"
    echo "Like so:"
    echo ""
    echo "bosh_target warden --refresh"
    echo "bosh_deployment diego"
    return 1
  fi

  export EXECUTOR_ADDR=http://`bosh_ip cell`:1700
  export ETCD_CLUSTER=http://`bosh_ip etcd`:4001
}
