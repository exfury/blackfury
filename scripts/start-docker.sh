#!/bin/bash

KEY="mykey"
CHAINID="blackfury_9000-1"
MONIKER="mymoniker"
DATA_DIR=$(mktemp -d -t blackfury-datadir.XXXXX)

echo "create and add new keys"
./blackfuryd keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --algo "eth_secp256k1" --keyring-backend test
echo "init blackfury with moniker=$MONIKER and chain-id=$CHAINID"
./blackfuryd init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./blackfuryd add-genesis-account \
"$(./blackfuryd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 1000000000000000000ablackfury,1000000000000000000stake \
--home $DATA_DIR --keyring-backend test
echo "prepare genesis: Sign genesis transaction"
./blackfuryd gentx $KEY 1000000000000000000stake --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./blackfuryd collect-gentxs --home $DATA_DIR
echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./blackfuryd validate-genesis --home $DATA_DIR

echo "starting blackfury node $i in background ..."
./blackfuryd start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log 2>&1 & disown

echo "started blackfury node"
tail -f /dev/null