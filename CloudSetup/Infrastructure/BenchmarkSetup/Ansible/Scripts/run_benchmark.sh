#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Variables
SUT_IP=$(cat /opt/postgres_server_ip.txt)
#SCRIPTS_DIR="HammerDB-4.9/scripts/tcl/postgres/tprocc/"
SCRIPTS=("pg_tprocc_buildschema.tcl" "pg_tprocc_deleteschema.tcl" "pg_tprocc_run_new.tcl")
TIME_DIR=" ../../../../config"
TIME_FILE="generic.xml"
TIME_PROF="etprof"

print_message "CAUTION: Terminal from HammerDB is outputted!"

print_message "Setting up benchmark engine..."

sleep 3

# Output IP Adress of target host
print_message "Detected the following SUT IP Adress: $SUT_IP"

# Ping target host to verify connectivity
print_message "Pinging target host to verify connectivity..."

if ping -c 4 $SUT_IP > /dev/null 2>&1; then
    print_message "Server reachable & ready for benchmark run!"
else 
    print_message "Ping failed...Server not reachable..."
fi

sleep 3

print_message "Checking if postgres-server is reachable..."

if nc -zvw3 $SUT_IP 5432; then
    print_message "Postgres is running, ready for benchmark run."
else
    print_message "Ping failed. Verify, if Postgres is correctly setup..."
fi

sleep 2

# Insert IP of target host into hammerdb tcl-scripts
for script in "${SCRIPTS[@]}"; do
    print_message "Updating $script with SUT_IP: $SUT_IP"
    sed -i "s/localhost/$SUT_IP/g" "$script"
done

#sed -i "s/127.0.0.1/$SUT_IP/g" "

print_message "TCL scripts are updated successfully!"

sleep 3

print_message "Setting TimeProfile for upcoming benchmark run. NOTE: Profile needs to be selected before first run!!!"

cd $TIME_DIR

print_message "Changing Time Config..."

sed -i "s/xtprof/$TIME_PROF/g" "$TIME_FILE"

print_message "etprof is successfully set as time profile."

sleep 5

cd ..

export TMP=`pwd`/TMP
mkdir -p $TMP
sudo chmod -R 777 /opt/HammerDB-4.9/TMP/
sudo touch pg_tprocc

print_message "BUILD HAMMERDB SCHEMA"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_buildschema.tcl 
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"

print_message "Schema is build!"

sleep 3

read -p "Do you want to run the interruptor application? (y/n) " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ssh -t niklas@$SUT_IP "cd /opt; sudo nohup bash /opt/resource_monitor.sh > /tmp/resource_monitor.log 2>&1 & disown; sudo nohup bash /opt/run_interruptor.sh > /tmp/exhaustor.log 2>&1 & disown; sleep 5; exit"
else
    ssh -t niklas@$SUT_IP "cd /opt; sudo nohup bash /opt/resource_monitor.sh > /dev/null 2>&1 & sleep 5; exit"
fi


sleep 5

echo "RUN HAMMERDB TEST"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_run_new.tcl 
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
echo "DROP HAMMERDB SCHEMA"
./hammerdbcli auto ./scripts/tcl/postgres//tprocc/pg_tprocc_deleteschema.tcl
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"
echo "HAMMERDB RESULT"
./hammerdbcli auto ./scripts/tcl/postgres/tprocc/pg_tprocc_result.tcl 

# Kill the ressource monitor
ssh -t niklas@$SUT_IP "sudo pkill -f 'resource_monitor.sh'; sleep 5; exit"

