#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -ex


function addnodes(){
  for org in {1..2}; do
    for id in {20..29}; do

      echo "
    peer${id}.org${org}.example.com:
      container_name: peer${id}.org${org}.example.com
      extends:
        file: ../base/peer-base.yaml
        service: peer-base
      environment:
        - CORE_PEER_ID=peer${id}.org${org}.example.com
        - CORE_PEER_ADDRESS=peer${id}.org${org}.example.com:${port}
        - CORE_PEER_LISTENADDRESS=0.0.0.0:${port}
        - CORE_PEER_CHAINCODEADDRESS=peer${id}.org${org}example.com:${ports}
        - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:${ports}
        - CORE_PEER_GOSSIP_BOOTSTRAP=peer1.org1.example.com:8051
        - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer${id}.org${org}.example.com:${port}
        - CORE_PEER_LOCALMSPID=Org1MSP
        - CORE_OPERATIONS_LISTENADDRESS=peer${id}.org${org}.example.com:${id}443
        - CORE_METRICS_PROVIDER=prometheus
      volumes:
          - /var/run/:/host/var/run/
          - ../crypto-config/peerOrganizations/org${org}.example.com/peers/peer${id}.org${org}.example.com/msp:/etc/hyperledger/fabric/msp
          - ../crypto-config/peerOrganizations/org${org}.example.com/peers/peer${id}.org${org}.example.com/tls:/etc/hyperledger/fabric/tls
          - peer${id}.org${org}.example.com:/var/hyperledger/production
      ports:
        - ${port}:${port}
    " >> docker-compose-add20.yaml

      ((port=$port+1000))
      ((ports=$port+1))
    done
  done

}

function addOrderer(){
  pport=7050
  for org in {1..2}; do
    for id in {1..10}; do
      echo "
  orderer${id}.ord${org}.example.com:
    extends:
      file: base/peer-base.yaml
      service: orderer-base 
    container_name: orderer${id}.ord${org}.example.com
    environment:
      - ORDERER_OPERATIONS_LISTENADDRESS=orderer${id}.ord${org}.example.com:8443
      - ORDERER_METRICS_PROVIDER=prometheus
      - ORDERER_GENERAL_LISTENPORT=${pport}
      - ORDERER_GENERAL_LOCALMSPID=Ord${org}MSP
    networks:
      - byfn
    volumes:
      - channel-artifacts/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
      - crypto-config/ordererOrganizations/ord${org}.example.com/orderers/orderer${id}.ord${org}.example.com/msp:/var/hyperledger/orderer/msp
      - crypto-config/ordererOrganizations/ord${org}.example.com/orderers/orderer${id}.ord${org}.example.com/tls/:/var/hyperledger/orderer/tls
      - orderer${id}.ord${org}.example.com:/var/hyperledger/production/orderer
    ports:
      - ${pport}:${pport}
    " >> docker-compose-add10-orderer.yaml

    ((pport=$pport+1000))
    done
  done

}



function addCoubdb(){
  pport=25084
  num=20
  for org in {1..2}; do
    for id in {10..19}; do
      echo "
  couchdb${num}:
    container_name: couchdb${num}
    image: couchdb:2.3

    environment:
      - COUCHDB_USER=
      - COUCHDB_PASSWORD=

    ports:
      - \"$pport:5984\"
    networks:
      - byfn

  peer${id}.org${org}.example.com:
    environment:
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb${num}:5984
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
    depends_on:
      - couchdb${num}
    " >> docker-compose-add10-couchdb.yaml

    ((pport=$pport+1000))
    ((num=$num+1))
    done
  done
}

#addCoubdb

addOrderer

#port=47051
#((ports=${port}+1))

#addnodes 10 ${num}


