function lite_me_up() {
  if [[ -z "$1" ]] || ( [[ "$1" != "--hard" ]] && [[ "$1" != "--soft" ]] ) ; then
    echo "lite_me_up: redeploy cf + diego to bosh-lite"
    echo "usage: lite_me_up --soft to simply perform a deploy"
    echo "usage: lite_me_up --hard to nuke the bosh-lite vm and start from scratch";
  fi

  for DIR in $HOME/workspace/bosh-lite $HOME/workspace/cf-release $HOME/workspace/diego-release ; do
    if [[ ! -d $DIR ]] ; then
      echo "You must clone $DIR"
    fi
  done

  touch /Users/pivotal/.bosh_warden_config

  if [[ "$1" == "--hard" ]]; then
    read -p "Will nuke bosh-lite's vm -- are you sure? " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]];then
      return 1
    fi

    pushd ~/workspace/bosh-lite
      echo "Destroying BOSH-lite VM"
      vagrant destroy -f
      echo "Bringing up BOSH-lite VM"
      vagrant up
    popd
  fi

  pushd ~/workspace/bosh-lite
    echo "Targetting the director"
    bosh -c $HOME/.bosh_warden_config target 192.168.50.4
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 login admin admin
    echo "Adding routes"
    ./scripts/add-route

    if [[ ! -a bosh-stemcell-17-warden-boshlite-ubuntu-trusty-go_agent.tgz ]]; then
      echo "Fetching trusty stemcell"
      bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 download public stemcell bosh-stemcell-17-warden-boshlite-ubuntu-trusty-go_agent.tgz
    fi

    echo "Uploading trusty stemcell"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4  upload stemcell bosh-stemcell-17-warden-boshlite-ubuntu-trusty-go_agent.tgz
  popd

  echo "Fetching latest spiff"
  go get -u -v github.com/cloudfoundry-incubator/spiff


  pushd ~/workspace/diego-release
      echo "Updating Diego-Release"
      git checkout develop
      ./scripts/update

      echo "Generating warden stub"
      mkdir -p ~/workspace/deployments/warden
      printf "director_uuid: %s" $(bosh -c $HOME/.bosh_warden_config status --uuid) > ~/workspace/deployments/warden/director.yml
  popd

  pushd ~/workspace/cf-release
    echo "Updating CF-Release"
    git checkout runtime-passed
    ./update

    echo "Generating CF-Release's manifest"
    ./generate_deployment_manifest warden \
        ~/workspace/deployments/warden/director.yml \
        ~/workspace/diego-release/templates/enable_diego_in_cc.yml > \
        ~/workspace/deployments/warden/cf.yml

    echo "Setting deployment to CF-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 deployment ~/workspace/deployments/warden/cf.yml

    echo "Creating CF-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/cf.yml create release --force

    echo "Uploading CF-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/cf.yml -n upload release

    echo "Deploying CF-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/cf.yml -n deploy
  popd

  pushd ~/workspace/diego-release
    echo "Generating Diego-Release's manifest"
    ./generate_deployment_manifest warden ../cf-release \
        ~/workspace/deployments/warden/director.yml > \
        ~/workspace/deployments/warden/diego.yml

    echo "Setting deployment to Diego-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 deployment ~/workspace/deployments/warden/diego.yml

    echo "Creating Diego-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/diego.yml create release --force

    echo "Uploading Diego-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/diego.yml -n upload release

    echo "Deploying Diego-Release"
    bosh -c $HOME/.bosh_warden_config -t 192.168.50.4 -d ~/workspace/deployments/warden/diego.yml -n deploy
  popd

  read -p "Done.  Do you want to setup bosh cache?  This will target warden globally. " -n 1
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]];then
    return 1
  fi

  echo "Setting up bosh cache"
  bosh_target warden --refresh
}
