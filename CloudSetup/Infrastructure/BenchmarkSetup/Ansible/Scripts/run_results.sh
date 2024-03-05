# Docker
# cd scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark.log
# awk '/PERCENTILES/,/FIN on/{print}' scripts/tcl/postgres/tprocc/full_benchmark.log > filtered_transaction_data.log
# gcloud compute ssh --zone "us-central1-c" "hammerdb2-instance" --project "ssws23" -- "cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo awk '/PERCENTILES/,/FIN on/{print}' full_benchmark.log > filtered_transaction_data.log"
# gcloud compute scp --zone "us-central1-c" "hammerdb2-instance:/opt/HammerDB-4.9/scripts/tcl/postgres/tprocc/filtered_transaction_data.log" "/home/niklas/Nextcloud/repos/ssws/Scalable-Software-Systems-PJ-TU-Berlin/ExperimentsAndResults/SUT_1/data"
# Add fetching of ressource file here

# LXC
# cd scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark_2.log
# awk '/PERCENTILES/,/FIN on/{print}' scripts/tcl/postgres/tprocc/full_benchmark_2.log > filtered_transaction_data_2.log
# gcloud compute ssh --zone "us-central1-c" "hammerdb2-instance" --project "ssws23" -- "cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo awk '/PERCENTILES/,/FIN on/{print}' full_benchmark_2.log > filtered_transaction_data_2.log"
# gcloud compute scp --zone "us-central1-c" "hammerdb2-instance:/opt/HammerDB-4.9/scripts/tcl/postgres/tprocc/filtered_transaction_data_2.log" "/home/niklas/Nextcloud/repos/ssws/Scalable-Software-Systems-PJ-TU-Berlin/ExperimentsAndResults/SUT_2/data"
# Add fetching of ressource file here

# Firecracker
# cd scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark_3.log
# awk '/PERCENTILES/,/FIN on/{print}' scripts/tcl/postgres/tprocc/full_benchmark_3.log > filtered_transaction_data_3.log
# gcloud compute ssh --zone "us-central1-c" "hammerdb2-instance" --project "ssws23" -- "cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo awk '/PERCENTILES/,/FIN on/{print}' full_benchmark_3.log > filtered_transaction_data_3.log"
# gcloud compute scp --zone "us-central1-c" "hammerdb2-instance:/opt/HammerDB-4.9/scripts/tcl/postgres/tprocc/filtered_transaction_data_3.log" "/home/niklas/Nextcloud/repos/ssws/Scalable-Software-Systems-PJ-TU-Berlin/ExperimentsAndResults/SUT_3/data"
# Add fetching of ressource file here


