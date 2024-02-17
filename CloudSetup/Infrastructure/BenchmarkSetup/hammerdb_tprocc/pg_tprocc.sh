#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Variables
SUT_IP=$(cat ~/opt/postgres_server_ip.txt)
#SCRIPTS_DIR="HammerDB-4.9/scripts/tcl/postgres/tprocc/"
SCRIPTS=("pg_tprocc_buildschema.tcl" "pg_tprocc_deleteschema.tcl" "pg_tprocc_run")

print_message "Setting up benchmark engine..."

sleep 3

# Output IP Adress of target host
print_message "Detected the following SUT IP Adress: $SUT_IP"

# Ping target host to verify connectivity
print_message "Pinging target host to verify connectivity..."

if ping -c 4 $SUT_IP > /dev/null 2>&1; then
    print_message "Server reachable & ready for benchmark run"
else 
    print_message "Ping failed...Server not reachable..."
fi

print_message "Checking if postgres-server is reachable..."

if nc -zvw3 $SUT_IP 5432; then
    print_message "Postgres is up&running, ready for benchmark run."
else
    print_message "Ping failed. Verify, if Postgres is correctly setup..."
fi

sleep 2

# Insert IP of target host into hammerdb tcl-scripts
for script in "${SCRIPTS[@]}"; do
    print_message "Updating $script with SUT_IP: $SUT_IP"
    sed -i "s/localhost/$SUT_IP/g" "$script"
done

print_message "TCL scripts are updated successfully!"

sleep 2

sudo export TMP=`pwd`/TMP
sudo mkdir -p $TMP

print_message "BUILD HAMMERDB SCHEMA"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_buildschema.tcl 
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"

sleep 3
print_message "SCHEMA IS LOADED INTO POSTGRES, BENCHMARK RUN STARTS IN 3 SECONDS..."

sleep 3

echo "RUN HAMMERDB TEST"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_run.tcl 
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
echo "DROP HAMMERDB SCHEMA"
./hammerdbcli auto ./scripts/tcl/postgres//tprocc/pg_tprocc_deleteschema.tcl
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
echo "HAMMERDB RESULT"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_result.tcl 
