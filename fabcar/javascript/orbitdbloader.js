const IPFS = require('ipfs')
const OrbitDB = require('orbit-db')
const fs = require('fs');

const data = require("/Users/kavyaub/Downloads/data1.json");
var parsedDate = JSON.parse(data);

// For js-ipfs >= 0.38

// Create IPFS instance
const initIPFSInstance = async () => {
  return await IPFS.create({ repo: "./path-for-js-ipfs-repo" });
};

initIPFSInstance().then(async ipfs => {

    const orbitdb = await OrbitDB.createInstance(ipfs)
    const db = await orbitdb.keyvalue('car-database')
    console.log(db.address.toString())
    await db.load();
    //const hash = await db.put('name', 'hello')
    //const value = db.get('name')
    //console.log(hash)
    //const hash2 = await db.put('name2', 'hello')
    //console.log(hash2)
    var hashes=[];

    //for (let i = 0; i < parsedDate.length; i+=2) {
    var j = 0
    var len = Object.keys(parsedDate).length
    console.log(len)
    for (let i = 1; i <= (len*2); i+=2) {
        var val={}
        val['CAR'+i] = await db.put('CAR'+i, Buffer.from(JSON.stringify(parsedDate[i])))
        hashes[j++]=val
        console.log("stored "+i);
    }

    //console.log(hashes)

    // Add line by line to the output
    //for(var i=0;i<hashes.length;i++) {
    //    output += Object.keys(hashes[i]).join(',') + Object.values();
    //}

    // Write to a file
    fs.writeFile("test.json", JSON.stringify(hashes), function(err) {
        if(err) return console.log(err);
        console.log("The file was saved!");
    }); 
    console.log(db.address.toString())
    db.load()
  // Create / Open a database
  //const db = await orbitdb.log("hello");
  //await db.load();

  // Listen for updates from peers
  //db.events.on("replicated", address => {
  //  console.log(db.iterator({ limit: -1 }).collect());
  //});

  // Add an entry
  //const hash = await db.add("world");
  //console.log(hash);

  // Query
  //const result = db.iterator({ limit: -1 }).collect();
  //console.log(JSON.stringify(result, null, 2));
});

