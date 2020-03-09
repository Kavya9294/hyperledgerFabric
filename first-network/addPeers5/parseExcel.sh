#!/bin/bash
docker logs orderer1.ord1.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt
docker logs orderer2.ord1.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt
docker logs orderer3.ord1.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt

docker logs orderer1.ord2.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt
docker logs orderer2.ord2.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt
docker logs orderer3.ord2.example.com 2>&1 | grep orderer.consensus.etcd | grep -v byfn-sys-channel >> sample.txt

cat sample.txt | awk '{print($2)}' >> sample2.txt
cat sample.txt | awk '{print($5)}' >> sample3.txt
cat sample.txt | awk '{print substr($0,length,1)}' >> sample4.txt

cut -d' ' -f1,2,3,4,5,6,7,8 --complement sample.txt | sed 's/node=.*//g' | sed 's/,//g'>> sample5.txt

paste -d, sample2.txt sample3.txt sample4.txt sample5.txt > sample1.txt
sed  -i '1i Time, Operation, Node, Description' sample1.txt
cat sample1.txt > sample1.xlsx