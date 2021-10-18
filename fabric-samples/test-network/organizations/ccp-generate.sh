#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${COMP}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${COMP}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

COMP=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/comp1.example.com/tlsca/tlsca.comp1.example.com-cert.pem
CAPEM=organizations/peerOrganizations/comp1.example.com/ca/ca.comp1.example.com-cert.pem

echo "$(json_ccp $COMP $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/comp1.example.com/connection-comp1.json
echo "$(yaml_ccp $COMP $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/comp1.example.com/connection-comp1.yaml

COMP=2
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/comp2.example.com/tlsca/tlsca.comp2.example.com-cert.pem
CAPEM=organizations/peerOrganizations/comp2.example.com/ca/ca.comp2.example.com-cert.pem

echo "$(json_ccp $COMP $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/comp2.example.com/connection-comp2.json
echo "$(yaml_ccp $COMP $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/comp2.example.com/connection-comp2.yaml
