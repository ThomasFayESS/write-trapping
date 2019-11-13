echo "Writing to PVs in production environment can be damage equipment if adequate precuations have not been taken."
echo "Please ensure equipment is in a state where PV writes do not pose risk of damaging equipment."
echo "If you are sure the appropriate precautions have been taken, please enter PROCEED to continue testing PV write trapping."

read confirm

[[ $confirm != "PROCEED" ]] && echo "exiting..." && exit 1


preamble="Class Name: "

function caput_test()
{
  curVal=$(caget -t $1) 
  a=$(caput $1 $curVal 2>&1 | grep 'Error from put operation: Write access denied')
  [[ ${#a} -gt 0 ]] && echo "....caput remote write to PV '$1' trapped."
}

function pvput_test()
{
  curVal=$(caget -t $1 2>&1) 
  a=$(pvput $1 $curVal 2>&1 | grep 'Error: Put not permitted')
  [[ ${#a} -gt 0 ]] && echo "....pvput remote write to PV '$1' trapped."
}

for PV in `cat ./listPV`
do
  echo "Testing PV: $PV"

  recordType=$(caget $PV -d 38 2>&1 | grep 'Class Name:')
  [[ $recordType == *"timed out"* ]] && echo "Couldn't find PV on network, exiting... " && exit

  [[ $recordType == *ai* ]] && recordType="ai" && echo "ai record" && declare -a arrFields=(VAL HIGH HIHI LOW LOLO)
  [[ $recordType == *ao* ]] && recordType="ao" && echo "ao record" && declare -a arrFields=(VAL OROC DRVH DRVL HIGH HIHI LOW LOLO)
  [[ $recordType == *bi* ]] && recordType="ai" && echo "bi record" && declare -a arrFields=(VAL)
  [[ $recordType == *bo* ]] && recordType="ao" && echo "bo record" && declare -a arrFields=(VAL)
  # No write checking required for strings or waveforms.
  [[ $recordType == *string* ]] && recordType="" && echo "..skipping string PV" && declare -a arrFields=()
  [[ $recordType == *waveform* ]] && recordType="" && echo "..skipping waveform PV" && declare -a arrFields=()
  

  # Test if remote write is trapped correctly for caput and pvput
  # Important to test both Channel Access and PV access remote writes.
  if [[ ${#arrFields[@]} -gt 0 ]]; then
    echo "..Testing individual fields..."
    for field in "${arrFields[@]}"
    do
      caput_test "$PV.$field"
      pvput_test "$PV.$field"
    done 
  fi 

  unset arrField
done
