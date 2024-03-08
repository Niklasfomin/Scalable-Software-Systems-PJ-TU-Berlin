#!/bin/bash

SUT_IP=$(cat /opt/postgres_server_ip.txt)

: "${DIALOG_OK=0}"
: "${DIALOG_CANCEL=1}"
: "${DIALOG_HELP=2}"
: "${DIALOG_EXTRA=3}"
: "${DIALOG_ITEM_HELP=4}"
: "${DIALOG_ESC=255}"

while true; do
  exec 3>&1
  selection=$(dialog \
  --backtitle "Experiment Wizard" \
  --title "Select SUT Setup Script" \
  --clear \
  --cancel-label "Exit" \
  --menu "Please select:" 15 50 6 \
  "1" "Setup Docker PostgreSQL" \
  "2" "Setup LXC PostgreSQL" \
  "3" "Setup QEMU" \
  "4" "Run Benchmark" \
  "5" "Clean the SUT Server" \
  "6" "Process benchmark results" \
  2>&1 1>&3)
  exit_status=$?
  exec 3>&-

  case $exit_status in
      $DIALOG_CANCEL)
          clear
          echo "Program terminated."
          exit
          ;;
      $DIALOG_ESC)
          clear
          echo "Program aborted." >&2
          exit 1
          ;;
  esac

  case $selection in
    1)
      echo "Launching SUT..."
      ssh -t niklas@$SUT_IP "sudo bash /opt/setup_docker_pg.sh > /tmp/setup_docker_pg.log 2>&1 & sleep 10; exit"
      echo "SUT running!"
      ;;
    2)
      echo "Launching SUT..."
      ssh -t niklas@$SUT_IP "sudo bash /opt/setup_lxc_pg.sh > /tmp/setup_lxc_pg.log 2>&1 & sleep 10; exit"
      echo "SUT running!"
      ;;
    3)
      echo "Launching SUT..."
      ssh -t niklas@$SUT_IP "sudo bash setup_qemu.sh"
      echo "SUT running!"
      ;;
    4)
      echo "Run Experiment"
      bash run_benchmark.sh 2>&1 | tee full_benchmark.log
      ;;
    5)
      echo "Cleaning the SUT Server..." 
      ssh -t niklas@$SUT_IP "sudo bash /opt/cleanup.sh > /tmp/cleanup.log 2>&1 & sleep 10; exit"
      echo "No SUTs running!"
      ;;
    6) 
      echo "Extracting Benchmark results..."
      awk '/PERCENTILES/,/FIN on/{print}' full_benchmark.log > filtered_transaction_data.log
      ;;
  esac
done