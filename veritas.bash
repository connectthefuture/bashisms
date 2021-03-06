function edge_envs() {
  export LOGGREGATOR_ADDR=loggregator.192.168.11.11.xip.io
  export DIEGO_RECEPTOR_ADDRESS=receptor.192.168.11.11.xip.io
  export RECEPTOR_ENDPOINT=receptor.192.168.11.11.xip.io
  export EXECUTOR_ADDR=http://192.168.11.11:1700
  export ETCD_CLUSTER=http://192.168.11.11:4001
  export GARDEN_ADDR=192.168.11.11:7777
  export GARDEN_NETWORK="tcp"
}

function veritas_envs() {
  if [[ `get_bosh_target` != "warden" ]] ; then
    echo "You must use bosh cache and set the target to 'warden'"
    echo "Like so:"
    echo ""
    echo "bosh_target warden --refresh"
    return 1
  fi

  export LOGGREGATOR_ADDR=`bosh_ip loggregator_z1/0 cf-warden`:8080

  export EXECUTOR_ADDR=http://`bosh_ip cell warden-diego`:1700
  export ETCD_CLUSTER=http://`bosh_ip etcd warden-diego`:4001
  export GARDEN_ADDR=`bosh_ip cell warden-diego`:7777
  export GARDEN_NETWORK="tcp"
  export VITALS_ADDRS="\
auctioneer:`bosh_ip brain warden-diego`:17001,\
converger:`bosh_ip brain warden-diego`:17002,\
etcd_metrics_server:`bosh_ip etcd warden-diego`:17003,\
executor:`bosh_ip cell warden-diego`:17004,\
file_server:`bosh_ip cc_bridge warden-diego`:17005,\
nsync-listener:`bosh_ip cc_bridge warden-diego`:17006,\
nsync-bulker:`bosh_ip cc_bridge warden-diego`:17007,\
receptor:`bosh_ip cell warden-diego`:17014,\
rep:`bosh_ip cell warden-diego`:17008,\
route-emitter:`bosh_ip route_emitter_z1/0 warden-diego`:17009,\
runtime-metrics-server:`bosh_ip brain warden-diego`:17010,\
stager:`bosh_ip cc_bridge warden-diego`:17011,\
tps:`bosh_ip cc_bridge warden-diego`:17012,\
garden:`bosh_ip cell warden-diego`:17013"
  export DROPSONDE_ORIGIN=veritas
  export DROPSONDE_DESTINATION=localhost:3457
  export LTC_TARGET=`bosh_ip ha_proxy_z1/0 cf-warden`.xip.io

  echo "EXECUTOR_ADDR=$EXECUTOR_ADDR"
  echo "LOGGREGATOR_ADDR=$LOGGREGATOR_ADDR"
  echo "GARDEN_ADDR=$GARDEN_ADDR"
  echo "GARDEN_NETWORK=$GARDEN_NETWORK"
  echo "ETCD_CLUSTER=$ETCD_CLUSTER"
  echo "VITALS_ADDRS=$VITALS_ADDRS"
  echo "LTC_TARGET=$LTC_TARGET"
}
