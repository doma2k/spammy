#!/bin/bash

set -ue

# Constants
APPNAME="celestia-appd"
CHANNEL="channel-0"
ADDRESS="celestia1x7jn3tafxdhk844vgle5ga4plyqqxk39z4zsnk"
IBCMEMO=50000
RECIEVEADDR=100000
GAS=3114054
CHAINID="mocha-4"
IBCTIMEOUTS="--packet-timeout-timestamp 0 --packet-timeout-height 0-100000"
FEES=391405
UDENOM="utia"
# Retrieve account details (Placeholder: Replace with actual curl command if needed)
ACCOUNT=72559

# Outer loop to handle sequence number
while true; do

    # Retrieve sequence
    SEQUENCE=$(curl http://127.0.0.1:5003/cosmos/auth/v1beta1/accounts/$ADDRESS | jq --raw-output ' .account.sequence ')
    
    # Inner loop to handle payload delivery
    while true; do

        echo "Sequence number is $SEQUENCE"

        # Generate new transaction body with a random string
        $APPNAME tx ibc-transfer transfer transfer $CHANNEL $ADDRESS 1$UDENOM  \
            --keyring-backend test --memo $(openssl rand -hex $IBCMEMO) --chain-id $CHAINID --yes $IBCTIMEOUTS \
            --generate-only --fees $FEES$UDENOM --gas $GAS --from $ADDRESS &> bareibctx.json
        echo "Transaction body generated with $((IBCMEMO*2)) byte IBC memo field"

        # Generate random hex string and set it to the receiver field
        openssl rand -hex $RECIEVEADDR > tmp.txt
        echo "Random string generated"
        jq --rawfile random_str tmp.txt '.body.messages[0].receiver = $random_str' bareibctx.json > autobanana.json
        echo "$(($RECIEVEADDR*2)) byte random string inserted"
        
        # Remove temporary file
        rm tmp.txt
        echo "Temporary file removed"

        # Sign the transaction
        $APPNAME tx sign autobanana.json --from $ADDRESS --yes --sequence $SEQUENCE \
            --chain-id $CHAINID --keyring-backend test --offline --account-number $ACCOUNT &> ban.json
        echo "Transaction signed"

        # Broadcast the transaction
        $APPNAME tx broadcast ban.json > banana.log
        cat banana.log
        echo "Transaction broadcasted"

        # Check for a sequence number mismatch
        if [ $(grep -c "mismatch" banana.log) -eq 1 ]; then
            echo "Sequence number mismatch"
            break
        fi

        # Update sequence number for next iteration
        SEQUENCE=$(($SEQUENCE+1))

    done

done

echo "If you're running it right, the script just restarted"
