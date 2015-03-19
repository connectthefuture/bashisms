function fetch_latest_ltc() {
  echo "fetching latest ltc"
  mkdir -p $HOME/bin
  wget https://lattice.s3.amazonaws.com/unstable/latest/darwin-amd64/ltc -O $HOME/bin/ltc
  chmod +x $HOME/bin/ltc
}