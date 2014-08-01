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
  export VITALS_ADDRS="\
auctioneer:`bosh_ip cell`:17001,\
converger:`bosh_ip cell`:17002,\
etcd_metrics_server:`bosh_ip etcd`:17003,\
executor:`bosh_ip cell`:17004,\
file_server:`bosh_ip file_server_z1/0`:17005,\
nsync-listener:`bosh_ip cf_bridge`:17006,\
nsync-bulker:`bosh_ip cf_bridge`:17007,\
rep:`bosh_ip cell`:17008,\
route-emitter:`bosh_ip route_emitter_z1/0`:17009,\
runtime-metrics-server:`bosh_ip runtime_metrics_server`:17010,\
stager:`bosh_ip cf_bridge`:17011,\
tps:`bosh_ip cf_bridge`:17012,\
warden:`bosh_ip cell`:17013"

  echo "EXECUTOR_ADDR=$EXECUTOR_ADDR"
  echo "ETCD_CLUSTER=$ETCD_CLUSTER"
  echo "VITALS_ADDRS=$VITALS_ADDRS"
}
