# Command to run the benchmark: cd scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark.log
# awk '/PERCENTILES/,/FIN on/{print}' /scripts/tcl/postgres/tprocc/full_benchmark.log > filtered_transaction_data.log
