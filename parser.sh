#!/usr/bin/
#
inout="/Users/kavyaub/Documents/mySubjects/research/hyperledgerFabric/sampleLogs.txt"
while IFS= read -r line
do
  echo "$line"
done < "$input"
