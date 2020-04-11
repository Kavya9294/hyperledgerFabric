/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const data1 = require("/Users/kavyaub/Downloads/data1.json");
var parsedDate = JSON.parse(data1);

async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', 'first-network/addPeers5', 'connection-org1.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('user2');
        if (!identity) {
            console.log('An identity for the user "user2" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'user2', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('mychannel');

        // Get the contract from the network.
        const contract = network.getContract('fabcar');

        // Submit the specified transaction.
        // createCar transaction - requires 5 argument, ex: ('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom')
        // changeCarOwner transaction - requires 2 args , ex: ('changeCarOwner', 'CAR10', 'Dave')
        var startTime=new Date();
        var len = Object.keys(parsedDate).length
        //console.log(parsedDate[1])
        for (let i = 1; i <= len; i=i+2) {
            await contract.submitTransaction('createCar','CAR'+i, parsedDate[i]['time'],parsedDate[i]['id'],parsedDate[i]['type'],parsedDate[i]['link'],parsedDate[i]['lane'],parsedDate[i]['x'],parsedDate[i]['y'],parsedDate[i]['angle'],parsedDate[i]['speed'],parsedDate[i]['pos'],parsedDate[i]['direction']);
            console.log('Transaction has been submitted: '+i);
            //console.info('Added <--> ', parsedDate[i]);
        }
        //await contract.submitTransaction('createCar','Car21', '900','20_25_600_31', '1', '-139919720#0_1', '1', '1982.56', '3794.62', '331.48', '0', '85.01', 'NB');
        //console.log('Transaction 1 has been submitted');
        //await contract.submitTransaction('createCar','Car22', '900','20_25_600_39', '3', '-139919720#0_1', '1', '1978.6', '3801.91', '331.48', '0', '93.32', 'NB');
        //console.log('Transaction 2 has been submitted');
        //await contract.submitTransaction('createCar','Car23', '900','24_12_300_380', '5', '-139919720#0.114_2', '2', '1949.97', '3847.89', '331.48', '0.09', '35.97', 'NB');
        //console.log('Transaction 3 has been submitted');
        //await contract.submitTransaction('createCar','Car24', '900','25_12_600_236', '4', '222246981#3_0', '0', '1870.99', '4000.18', '157.93', '0', '110.79', 'SB');
        //console.log('Transaction 4 has been submitted');
        //await contract.submitTransaction('createCar','Car25', '900','25_12_600_249', '1', '222246981#3_0', '0', '1872.8', '3995.73', '157.93', '0', '115.59', 'SB');
        //console.log('Transaction 5 has been submitted');
        //await contract.submitTransaction('createCar','Car26', '900','25_12_600_328', '1', '222246981#3_0', '0', '1870.32', '4001.85', '157.93', '0', '108.98', 'SB');
        //console.log('Transaction 6 has been submitted');
        //console.log('All Transaction has been submitted');
        var endTime = new Date();
        var timeDiff = endTime - startTime; //in ms
        // strip the ms
        timeDiff /= 1000;

        // get seconds 
        var seconds = Math.round(timeDiff);
        console.log(timeDiff + " seconds to write");

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

main();
