nproc                       # confirms thread count: 8 on T480, 12 on P53

# run N parallel date-loops for ~10s, count total spawns across all cores
seq $(nproc) | xargs -P0 -I{} sh -c '
  end=$(( $(date +%s) + 10 ))
  n=0
  while [ $(date +%s) -lt $end ]; do date >/dev/null; n=$((n+1)); done
  echo $n
' | paste -sd+ | bc
