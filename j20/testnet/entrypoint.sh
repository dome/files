#!/bin/sh
set -exu

VERBOSITY=${GETH_VERBOSITY:-3}
GETH_DATA_DIR=/db
GETH_CHAINDATA_DIR="$GETH_DATA_DIR/geth/chaindata"
GETH_KEYSTORE_DIR="$GETH_DATA_DIR/keystore"
GENESIS_FILE_PATH="${GENESIS_FILE_PATH:-/genesis.json}"
CHAIN_ID=$(cat "$GENESIS_FILE_PATH" | jq -r .config.chainId)
BLOCK_SIGNER_PRIVATE_KEY="3e4bde571b86929bf08e2aaad9a6a1882664cd5e65b96fff7d03e1c4e6dfa15c"
BLOCK_SIGNER_ADDRESS="0xca062b0fd91172d89bcd4bb084ac4e21972cc467"
RPC_PORT="${RPC_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running init"
	echo "Initializing genesis."
	geth --verbosity="$VERBOSITY" init \
		--datadir="$GETH_DATA_DIR" \
		"$GENESIS_FILE_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

# Warning: Archive mode is required, otherwise old trie nodes will be
# pruned within minutes of starting the devnet.

exec geth \
	--datadir="$GETH_DATA_DIR" \
	--verbosity="$VERBOSITY" \
	--http \
	--http.corsdomain="*" \
	--http.vhosts="*" \
	--http.addr=0.0.0.0 \
	--http.port="$RPC_PORT" \
	--http.api=web3,debug,eth,txpool,net,engine \
	--ws \
	--ws.addr=0.0.0.0 \
	--ws.port="$WS_PORT" \
	--ws.origins="*" \
	--ws.api=debug,eth,txpool,net,engine \
	--syncmode=full \
	--nodiscover \
	--maxpeers=0 \
	--networkid=$CHAIN_ID \
	--allow-insecure-unlock \
	--authrpc.addr="0.0.0.0" \
	--authrpc.port="8551" \
	--authrpc.vhosts="*" \
	--rollup.disabletxpoolgossip=true \
	--rollup.sequencerhttp=http://65.109.26.7:9545 \
	--gcmode=archive \
	"$@"
