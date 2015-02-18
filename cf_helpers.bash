function cf_warden() {
  echo "logging into warden"
  cf api api.10.244.0.34.xip.io --skip-ssl-validation
  cf login -u admin -p admin -o onsi -s onsi
  cf create-org onsi
  cf target -o onsi
  cf create-space onsi
  cf target -s onsi
}

function cf_ketchup() {
  echo "logging into ketchup"
  cf api api.ketchup.cf-app.com --skip-ssl-validation
  cf login -u admin -p $KETCHUP_CF_PASSWORD -o onsi -s onsi
  cf create-org onsi
  cf target -o onsi
  cf create-space onsi
  cf target -s onsi
}

function cf_a1() {
  echo "logging into ketchup"
  cf api api.a1.cf-app.com --skip-ssl-validation
  cf login -u admin -p $KETCHUP_CF_PASSWORD -o onsi -s onsi
  cf create-org onsi
  cf target -o onsi
  cf create-space onsi
  cf target -s onsi
}

function cf_diego1() {
  echo "logging into diego-1"
  cf api api.diego-1.cf-app.com --skip-ssl-validation
  cf login -u admin -p $KETCHUP_CF_PASSWORD -o onsi -s onsi
  cf create-org onsi
  cf target -o onsi
  cf create-space onsi
  cf target -s onsi
}

function cf_diego2() {
  echo "logging into diego-2"
  cf api api.diego-2.cf-app.com --skip-ssl-validation
  cf login -u admin -p $KETCHUP_CF_PASSWORD -o onsi -s onsi
  cf create-org onsi
  cf target -o onsi
  cf create-space onsi
  cf target -s onsi
}

function cf_push() {
  cf push "$@" --no-start
  cf curl /v2/apps/`cf app $1 --guid` -X PUT -d '{"diego":true}'
  cf start $1
}
