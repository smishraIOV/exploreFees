import subprocess as sp
import time

for i in range(0, 2):
    sp.call(["node", "readBlocks.js", str(i)])
    time.sleep(2)


