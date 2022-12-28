#!/bin/sh
if [ ! -d /datadir/geth/chaindata ]; then
    echo "/datadir/geth/chaindata not found, running 'geth init'..."
    geth --datadir /datadir/geth  init /datadir/genesis.json
    echo "...done!"
fi

geth "$@"

