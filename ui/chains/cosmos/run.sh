#!/usr/bin/env bash

. ../credentials.sh
set -ev

parallelizr() {
  for cmd in "$@"; do {
    echo "Process \"$cmd\" started";
    $cmd & pid=$!
    PID_LIST+=" $pid";
  } done

  trap "kill $PID_LIST" SIGINT

  echo "Parallel processes have started";

  wait $PID_LIST

  echo "All processes have completed";
}

rm -rf ~/.sifnoded
rm -rf ~/.sifnodecli

sifnoded init test --chain-id=sifchain-local
cp ./config.toml ~/.sifnoded/config

#sifnoded config output json
#sifnoded config indent true
#sifnoded config trust-node true
#sifnoded config chain-id sifchain-local
#sifnoded config keyring-backend test

echo "Generating deterministic account - ${SHADOWFIEND_NAME}"
echo "${SHADOWFIEND_MNEMONIC}" | sifnoded keys add ${SHADOWFIEND_NAME} --recover --keyring-backend test --log_level info

echo "Generating deterministic account - ${AKASHA_NAME}"
echo "${AKASHA_MNEMONIC}" | sifnoded keys add ${AKASHA_NAME} --recover --keyring-backend test --log_level info

echo "Generating deterministic account - ${JUNIPER_NAME}"
echo "${JUNIPER_MNEMONIC}" | sifnoded keys add ${JUNIPER_NAME} --recover --keyring-backend test --log_level info

sifnoded add-genesis-account $(sifnoded keys show ${SHADOWFIEND_NAME} -a --keyring-backend test --log_level info) 100000000000000000000000000000rowan,100000000000000000000000000000catk,100000000000000000000000000000cbtk,100000000000000000000000000000ceth,100000000000000000000000000000cusdc,100000000000000000000000000000clink,100000000000000000000000000stake --log_level info
sifnoded add-genesis-account $(sifnoded keys show ${AKASHA_NAME} -a --keyring-backend test --log_level info) 100000000000000000000000000000rowan,100000000000000000000000000000catk,100000000000000000000000000000cbtk,100000000000000000000000000000ceth,100000000000000000000000000000cusdc,100000000000000000000000000000clink,100000000000000000000000000stake --log_level info
sifnoded add-genesis-account $(sifnoded keys show ${JUNIPER_NAME} -a --keyring-backend test --log_level info) 10000000000000000000000rowan,10000000000000000000000cusdc,100000000000000000000clink,100000000000000000000ceth --log_level info

sifnoded add-genesis-validators $(sifnoded keys show ${SHADOWFIEND_NAME} -a --bech val --keyring-backend test --log_level info) --log_level info

sifnoded gentx ${SHADOWFIEND_NAME} 1000000000000000000000000stake --keyring-backend test --log_level info --chain-id sifchain-local

echo "Collecting genesis txs..."
sifnoded collect-gentxs --log_level info

echo "Validating genesis file..."
sifnoded validate-genesis --log_level info

echo "Starting test chain"

parallelizr "sifnoded start" "sifnodecli rest-server  --unsafe-cors --trace"


#sifnoded start --log_level="main:info,state:error,statesync:info,*:error"
