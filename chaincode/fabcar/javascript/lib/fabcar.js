/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');
//const data1 = require("/Users/kavyaub/Downloads/data1.json");
//var parsedDate = JSON.parse(data1);

class FabCar extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const cars = [
            {
                time: '900',
                id: '10_25_600_355',
                type: '1',
                link: '-139919720#0_3',
                lane: '3',
                x: '1977.46',
                y: '3790.6',
                angle: '331.47',
                speed: '0',
                pos: '83.91',
                direction: 'NB',
            },
            {
                time: '900',
                id: '11_12_600_395',
                type: '2',
                link: '110155730#1_3',
                lane: '3',
                x: '1897.3',
                y: '3964.16',
                angle: '338.19',
                speed: '0.22',
                pos: '101.65',
                direction: 'NB',
            },
            {
                time: '900',
                id: '11_25_600_474',
                type: '1',
                link: '110155730#1_2',
                lane: '2',
                x: '1902.04',
                y: '3960.92',
                angle: '338.19',
                speed: '0',
                pos: '96.83',
                direction: 'NB',
            },
            {
                time: '900',
                id: '11_5_600_401',
                type: '1',
                link: '110155730#1_2',
                lane: '2',
                x: '1900.27',
                y: '3965.35',
                angle: '338.19',
                speed: '0.25',
                pos: '101.65',
                direction: 'NB',
            },
            {
                time: '900',
                id: '14_25_600_153',
                type: '1',
                link: '-139919720#0_1',
                lane: '1',
                x: '1971.38',
                y: '3815.2',
                angle: '331.48',
                speed: '0.25',
                pos: '108.44',
                direction: 'NB',
            },
            {
                time: '900',
                id: '14_5_300_474',
                type: '1',
                link: '-139919720#0_3',
                lane: '3',
                x: '1975.17',
                y: '3794.82',
                angle: '331.47',
                speed: '0',
                pos: '88.71',
                direction: 'NB',
            },
            {
                time: '900',
                id: '1_28_600_167',
                type: '1',
                link: '222246981#3_1',
                lane: '1',
                x: '1873.78',
                y: '4001.81',
                angle: '157.93',
                speed: '0',
                pos: '110.29',
                direction: 'NB',
            },
            {
                time: '900',
                id: '1_29_600_293',
                type: '1',
                link: '222246981#3_1',
                lane: '1',
                x: '1871.98',
                y: '4006.26',
                angle: '157.93',
                speed: '0',
                pos: '105.48',
                direction: 'NB',
            },
            {
                time: '900',
                id: '1_9_600_191',
                type: '1',
                link: '222246981#3_2',
                lane: '2',
                x: '1876.95',
                y: '4002.51',
                angle: '157.93',
                speed: '0',
                pos: '110.79',
                direction: 'NB',
            },
            {
                time: '900',
                id: '1_9_600_71',
                type: '1',
                link: '222246981#3_0',
                lane: '0',
                x: '1868.51',
                y: '4006.3',
                angle: '157.93',
                speed: '0',
                pos: '104.18',
                direction: 'NB',
            },
        ];

        for (let i = 0; i < cars.length; i++) {
            cars[i].docType = 'car';
            await ctx.stub.putState('CAR' + i, Buffer.from(JSON.stringify(cars[i])));
            console.info('Added <--> ', cars[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryCar(ctx, carNumber) {
        const carAsBytes = await ctx.stub.getState(carNumber); // get the car from chaincode state
        if (!carAsBytes || carAsBytes.length === 0) {
            throw new Error(`${carNumber} does not exist`);
        }
        console.log(carAsBytes.toString());
        return carAsBytes.toString();
    }

    async createCar(ctx, carNumber, time, id, type, link, lane, x, y, angle, speed, pos, direction) {
        console.info('============= START : Create Car ===========');

        const car = {
            time,
            id,
            type,
            link,
            lane,
            x,
            y,
            angle,
            speed,
            pos,
            direction,
        };

        await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
        console.info('============= END : Create Car ===========');
    }

    async queryAllCars(ctx) {
        const startKey = 'CAR0';
        const endKey = 'CAR600000';
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    async changeCarOwner(ctx, carNumber, newOwner) {
        console.info('============= START : changeCarOwner ===========');

        const carAsBytes = await ctx.stub.getState(carNumber); // get the car from chaincode state
        if (!carAsBytes || carAsBytes.length === 0) {
            throw new Error(`${carNumber} does not exist`);
        }
        const car = JSON.parse(carAsBytes.toString());
        car.owner = newOwner;

        await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
        console.info('============= END : changeCarOwner ===========');
    }

}

module.exports = FabCar;
