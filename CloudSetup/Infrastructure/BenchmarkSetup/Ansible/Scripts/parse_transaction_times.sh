# This script needs to sadly parse hammerDB's outputted transaction response times...

#!/bin/bash

# Define the log file
LOGFILE="benchmark_output.log"

# Use awk to process the input stream
awk '
  /Percentiles/ {logging=1}

  logging {print > "'"$LOGFILE"'"}

  /FINISHED SUCCESS/ {exit}
'
