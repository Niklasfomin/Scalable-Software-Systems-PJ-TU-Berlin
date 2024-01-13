#!/bin/bash

DB_TYPE="pg"  
DB_SERVER="172.17.0.2"  
DB_PORT="5432"  
DB_USER="niklas"  
DB_PASSWORD="password"  
DB_NAME="postgres"  

BENCHMARK_TYPE="tpcc"  
WAREHOUSES=2
RUN_TIME=300  

./hammerdbcli << EOF
dbset $DB_TYPE
dbset server $DB_SERVER
dbset port $DB_PORT
dbset user $DB_USER
dbset password $DB_PASSWORD
dbset db $DB_NAME
dbset tpcc $BENCHMARK_TYPE
dbset tpcc warehouses $WAREHOUSES
dbset tpcc runtime $RUN_TIME
runtptest
EOF

echo "HammerDB benchmark completed."
