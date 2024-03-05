#!/bin/bash

: "${DIALOG_OK=0}"
: "${DIALOG_CANCEL=1}"
: "${DIALOG_HELP=2}"
: "${DIALOG_EXTRA=3}"
: "${DIALOG_ITEM_HELP=4}"
: "${DIALOG_ESC=255}"

exec 3>&1
selection=$(dialog \
  --backtitle "Setup SUTs" \
  --title "Select SUT Setup Script" \
  --clear \
  --cancel-label "Exit" \
  --menu "Please select:" 15 50 4 \
  "1" "Setup Docker PostgreSQL" \
  "2" "Setup LXC PostgreSQL" \
  "3" "Setup Firecracker" \
  "4" "Clean the SUT Server" \ 
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

# Execute the desired script
case $selection in
  1)
    sudo bash setup_docker_pg.sh
    ;;
  2)
    sudo bash setup_lxc_pg.sh
    ;;
  3)
    sudo bash setup_firecracker.sh
    ;;
  4) 
    sudo bash cleanup.sh
    ;;
esac