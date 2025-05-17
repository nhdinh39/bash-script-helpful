#!/bin/bash

# Header labels
headers=("NODE_NAME" "INTERNAL_IP" "INSTANCE_ID" "AZ" "INSTANCE_TYPE")

# Dump raw rows (tab-separated)
rows=$(kubectl get nodes -o json | jq -r '
  .items[] |
  [
    .metadata.name,
    (.status.addresses[] | select(.type=="InternalIP") | .address),
    (.spec.providerID | split("/") | .[4]),
    (.spec.providerID | split("/") | .[3]),
    (
      .metadata.labels["node.kubernetes.io/instance-type"]
      // .metadata.labels["beta.kubernetes.io/instance-type"]
      // "unknown"
    )
  ] | @tsv
')

# Get max widths from data
mapfile -t max_widths < <(echo "$rows" | awk -F'\t' '
{
  for (i = 1; i <= NF; i++) {
    if (length($i) > max[i]) max[i] = length($i)
  }
}
END {
  for (i = 1; i <= length(max); i++) print max[i]
}')

# Compare with header lengths and pick longer
for i in "${!headers[@]}"; do
  header_len=${#headers[$i]}
  [[ ${max_widths[$i]:-0} -lt $header_len ]] && max_widths[$i]=$header_len
done

# Build table divider
divider="+"
for w in "${max_widths[@]}"; do divider+="$(printf '%0.s-' $(seq 1 $((w + 2))))+"; done

# Print header
echo "$divider"
printf "|"
for i in "${!headers[@]}"; do
  printf " %-${max_widths[$i]}s |" "${headers[$i]}"
done
echo
echo "$divider"

# Print rows
echo "$rows" | while IFS=$'\t' read -r -a fields; do
  printf "|"
  for i in "${!fields[@]}"; do
    printf " %-${max_widths[$i]}s |" "${fields[$i]}"
  done
  echo
done

# Footer
echo "$divider"
