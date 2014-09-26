#!/bin/bash
echo `pwd`
#find -exec ldd {} \; |wc -l
./npr -w phylomedb4 -a /tmp/Phy0007XAR_HUMAN.msf.aa -n /tmp/Phy0007XAR_HUMAN.msf.nt --dealign -o /tmp/tmpresult -v2 --clearall --override -t0.7 --launch_time 1 -C4 --compress --logfile
./nprdump -a /tmp/tmpresult/

touch test1
tar -zcf test1.tgz test1 && rm test1.tgz 
rm test1
 
touch test2
gzip test2 && rm test2.gz
rm test2

ldd /bin/tar
ldd /bin/gzip
ldd /bin/cp
ldd /bin/rm
ldd /bin/ln



