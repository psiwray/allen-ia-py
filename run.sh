#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Missing required arguments."
  echo "Usage: '$0 <time_intervals_file> <encoding> <log_file>'."
  exit -1
fi

time_intervals_file=$1
encoding=$2
log_file=output/$encoding/`basename $time_intervals_file`/log.txt

# First generate the required SAT data for every group in the time intervals file.
python3 -s main.py --data=data --coding=$encoding --output=output/$encoding/`basename $time_intervals_file` $time_intervals_file
if [[ $? -ne 0 ]]; then
  echo "Clause generation failed."
  exit -1
fi
echo "Output generation finished."

# Then, for every group, check that minisat can satisfy the boolean expression.
rm $log_file 2>/dev/null
rm $log_file.tmp 2>/dev/null
for sat_file in output/$encoding/`basename $time_intervals_file`/*.sat; do
  echo "Validating SAT output for group $sat_file..."
  echo "-----------------------------------------------" >> $log_file
  echo "  $sat_file" >> $log_file
  echo "-----------------------------------------------" >> $log_file
  echo "" >> $log_file
  minisat $sat_file 1> $log_file.tmp 2>&1
  grep "CPU time" $log_file.tmp
  cat $log_file.tmp >> $log_file
  rm $log_file.tmp
done

# Finally, print the result.
echo "Done. Now checking logs."
if [[ `grep "UNSATISFIABLE" $log_file | wc -l` -eq 0 ]]; then
  echo "No unsatisfiable groups found."
  exit 0
else
  echo "Some groups are unsatisfiable. Check $log_file for more information."
  exit -1
fi