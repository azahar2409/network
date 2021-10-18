#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_COMP1_CA=${PWD}/organizations/peerOrganizations/comp1.example.com/peers/peer0.comp1.example.com/tls/ca.crt
export PEER0_COMP2_CA=${PWD}/organizations/peerOrganizations/comp2.example.com/peers/peer0.comp2.example.com/tls/ca.crt
export PEER0_COMP3_CA=${PWD}/organizations/peerOrganizations/comp3.example.com/peers/peer0.comp3.example.com/tls/ca.crt

# Set environment variables for the peer COMP
setGlobals() {
  local USING_COMP=""
  if [ -z "$OVERRIDE_COMP" ]; then
    USING_COMP=$1
  else
    USING_COMP="${OVERRIDE_COMP}"
  fi
  infoln "Using organization ${USING_COMP}"
  if [ $USING_COMP -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Comp1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COMP1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/comp1.example.com/users/Admin@comp1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_COMP -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Comp2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COMP2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/comp2.example.com/users/Admin@comp2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_COMP -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Comp3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COMP3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/comp3.example.com/users/Admin@comp3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "COMP Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_COMP=""
  if [ -z "$OVERRIDE_COMP" ]; then
    USING_COMP=$1
  else
    USING_COMP="${OVERRIDE_COMP}"
  fi
  if [ $USING_COMP -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.comp1.example.com:7051
  elif [ $USING_COMP -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.comp2.example.com:9051
  elif [ $USING_COMP -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.comp3.example.com:11051
  else
    errorln "COMP Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.comp$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_COMP$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
