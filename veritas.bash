function veritas_up() {
  local bootstrap='
pushd $HOME
rm veritas

wget http://onsi-public.s3.amazonaws.com/veritas
chmod +x ./veritas
export PATH=$PATH:$PWD

veritas autodetect && `veritas autodetect`

veritas completions > ./.veritas_completions.bash
source ./.veritas_completions.bash
popd
'
  echo "Copied to clipboard:${bootstrap}"
  echo "$bootstrap" | pbcopy
}

function veritas_envs() {
  if [[ `get_bosh_target` != "warden" ]] ; then
    echo "You must use bosh cache and set the target to 'warden'"
    echo "Like so:"
    echo ""
    echo "bosh_target warden --refresh"
    return 1
  fi

  export LOGGREGATOR_ADDR=`bosh_ip loggregator_z1/0 cf-warden warden-diego`:8080

  export EXECUTOR_ADDR=http://`bosh_ip cell warden-diego`:1700
  export ETCD_CLUSTER=http://`bosh_ip etcd warden-diego`:4001
  export WARDEN_ADDR=`bosh_ip cell warden-diego`:7777
  export WARDEN_NETWORK="tcp"
  export VITALS_ADDRS="\
auctioneer:`bosh_ip cell warden-diego`:17001,\
converger:`bosh_ip cell warden-diego`:17002,\
etcd_metrics_server:`bosh_ip etcd warden-diego`:17003,\
executor:`bosh_ip cell warden-diego`:17004,\
file_server:`bosh_ip file_server_z1/0 warden-diego`:17005,\
nsync-listener:`bosh_ip cf_bridge warden-diego`:17006,\
nsync-bulker:`bosh_ip cf_bridge warden-diego`:17007,\
rep:`bosh_ip cell warden-diego`:17008,\
route-emitter:`bosh_ip route_emitter_z1/0 warden-diego`:17009,\
runtime-metrics-server:`bosh_ip runtime_metrics_server warden-diego`:17010,\
stager:`bosh_ip cf_bridge warden-diego`:17011,\
tps:`bosh_ip cf_bridge warden-diego`:17012,\
warden:`bosh_ip cell warden-diego`:17013"

  echo "EXECUTOR_ADDR=$EXECUTOR_ADDR"
  echo "LOGGREGATOR_ADDR=$LOGGREGATOR_ADDR"
  echo "WARDEN_ADDR=$WARDEN_ADDR"
  echo "WARDEN_NETWORK=$WARDEN_NETWORK"
  echo "ETCD_CLUSTER=$ETCD_CLUSTER"
  echo "VITALS_ADDRS=$VITALS_ADDRS"
}
