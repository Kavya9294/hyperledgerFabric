#!/bin/bash


CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

# import utils
. scripts/envVar.sh

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelTx() {

	set -x
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate channel configuration transaction..."
		exit 1
	fi
	echo

}

createAncorPeerTx() {

	for orgmsp in Org1MSP Org2MSP; do

	echo "#######    Generating anchor peer update for ${orgmsp}  ##########"
	set -x
	configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate anchor peer update for ${orgmsp}..."
		exit 1
	fi
	echo
	done
}

createChannel() {
	setGlobals 1 0

	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
				peer channel create -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block >&log.txt
				res=$?
        set +x
		else
				set -x
				peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer1.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
				res=$?
				set +x
		fi
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

# queryCommitted ORG


# joinChannel() {

# 	[[ $1 = 1 ]] && chArr=(0 1 2) || a=(0 1)
# 	echo "value if chArr is ${chArr[@]}"
#   	for org in 1 2; do
# 	    for peer in "${chArr[@]}"; do
# 		joinChannelWithRetry $org $peer
# 		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
# 		sleep $DELAY
# 		echo
# 	    done
# 	done
# }

# joinChannelWithRetry() {
#   ORG=$1
#   PEER=$2
#   setGlobals $ORG $PEER

#   set -x
#   peer channel join -b $CHANNEL_NAME.block >&log.txt
#   res=$?
#   set +x
#   cat log.txt
#   COUNTER=1
#   MAX_RETRY=20
#   DELAY=3
#   if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
#     COUNTER=$(expr $COUNTER + 1)
#     echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
#     sleep $DELAY
#     joinChannelWithRetry $PEER $ORG
#   else
#     COUNTER=1
#   fi
#   verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
# }


# queryCommitted ORG
joinChannel() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}



updateAnchorPeers() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer1.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer1.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channeltx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createChannelTx

## Create anchorpeertx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createAncorPeerTx

FABRIC_CFG_PATH=$PWD/../config/

## Create channel
echo "Creating channel "$CHANNEL_NAME
createChannel

## Join all the peers to the channel
echo "Join  org1 peer 0"
joinChannel 1 0
echo "Join  org1 peer 1"
joinChannel 1 1
echo "Join  org1 peer 2"
joinChannel 1 2
echo "Join  org2 peer 0"
joinChannel 2 0
echo "Join  org2 peer 1"
joinChannel 2 1


## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 1 0
echo "Updating anchor peers for org2..."
updateAnchorPeers 2 0

echo
echo "========= Channel successfully joined =========== "
echo

exit 0
