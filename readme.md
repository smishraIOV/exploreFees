# Aggregating Block level TXs and Fees

This is a simple exercise to measure the number of transactions and fees in RSK blocks. It is easy to view these metrics for any block using the [explorer](https://explorer.rsk.co/) on a browser or from a public RSK node from the terminal e.g.


```
curl   https://public-node.rsk.co   -X POST -H "Content-Type: application/json"   --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x4b9f44", false],"id":1}'
```

and then parsing the JSON in the response data.

This is **partially automated** using a script `src/readBlocks.js` to collect data from multiple calls.

Response data are appended to a file with the format. Each run of the script appends one row to a file `fees.csv`. If this file does not exist, create it with a header as follows.

```
RefBlock,BlockCount, TxCount, GasUsed, Timestamp
4809120,2494,2117,244526710,1668572069
...

```
 
 where `RefBlock` is the reference starting point. The initial goal was to query data for 20160 blocks (1 week's worth) starting from an initial block. However, that resulted in some timeout errors. So we reduced the number of rpc calls to 2520 (a factor 1/8th). Some rpc results still get dropped. Thus, we have to count how many of the 2520 requests were completed. This is represented as `BlockCount`. For these results, we add up the number of total transactions in `TxCount` and also the total fees in `GasUsed`. The `Timestamp` is just the timestamp from the `RefBlock`.

To obtain data in a weekly format, we sum 8 successive rows and plot the results. This is done using a R script `src/fees.r`. 

This is the first version and the scripts have not been optimized in any way. In fact to automate the process, I repeatedly called `readBlocks.js` using python ;) (not effificent)

```@python
import subprocess as sp

#starting block is already in js code, pass stopiing condition
for i in range(0, 2):
    sp.call(["node", "readBlocks.js", str(i)])
```

## Data
To avoid building things from scratch, a recent version of weekly data (last 5 years, until early January 2023) is availabe as `weekly.csv`. A [PDF plot](weeklyPlot.pdf) of transactions and fees (from this dataset) is also included.