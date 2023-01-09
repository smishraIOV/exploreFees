const { ethers, BigNumber } = require("ethers");

const  fs  = require("fs");

const { argv } = require('node:process');

const provider = new ethers.providers.JsonRpcProvider("http://localhost:4444/"); //for local node
//const provider = new ethers.providers.JsonRpcProvider("https://public-node.rsk.co"); // public ndoe for testing (few RPC calls)

//curl   http://localhost:4444/   -X POST -H "Content-Type: application/json"   --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

let window = argv[2];
console.log("Selected window: " + window);

const sleep = ms => new Promise(r => setTimeout(r, ms));

let numBlksToRewind = 2520 ;// others too high timeout rate 5040; //20160; // 7*24*60*2 = 20160 blocks per week, rpc timeout, use smaller number
const initblock = 4920000 -  (numBlksToRewind * window);

let stream = fs.createWriteStream("./fees.csv", {flags:'a'});
//stream.write("RefBlock,BlockCount,TxCount,GasUsed,Timestamp" +  "\n");

let fee = BigNumber.from(0);
let numTx = 0; //int (length of [tx])
let count = 0; //

// the order in which calls to this function get resolved 
// does not matter, since we only care about total fees and num Tx
async function getBlockData(blockNum){
    //if (blockNum % 50 == 0) {await sleep(100)}
    blk = await provider.getBlock(blockNum);
    fee = fee.add(blk.gasUsed);
    numTx = numTx + blk.transactions.length;
    count++;
    return blk.timestamp; 
}

let f0, f1;

for (let i=0; i<numBlksToRewind; i++){
    blk = initblock - i;

    if (i == numBlksToRewind -1) {
        sleep(2000); //wait 2 seconds for some more calls to get resolved
        f1 = Promise.resolve(getBlockData(blk));
        //by the time this gets resolved, most of the previous ones should have too
        f1.then((value) => {
        stream.write(initblock + "," + count + "," + (numTx-count) + "," + fee.toString() + "," + value +  "\n");
    });
    } else {       
        f0 = Promise.resolve(getBlockData(blk));
        f0.then((value) => {});
    }
}
