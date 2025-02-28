#!/bin/bash

NODESAPI=/api/v1/nodes

function getNodes() {
  kubectl get --raw $NODESAPI | jq -r '.items[].metadata.name'
}

function getPVCs() {
  jq -s '[flatten | .[].pods[].volume[]? | select(has("pvcRef")) | '\
'{namespace: .pvcRef.namespace, name: .pvcRef.name, capacityBytes, usedBytes, availableBytes, '\
'percentageUsed: (.usedBytes / .capacityBytes * 100)}] | sort_by(.name)'
}

function column() {
  awk '{ for (i = 1; i <= NF; i++) { d[NR, i] = $i; w[i] = length($i) > w[i] ? length($i) : w[i] } } '\
'END { for (i = 1; i <= NR; i++) { printf("%-*s", w[1], d[i, 1]); for (j = 2; j <= NF; j++ ) { printf("%*s", w[j] + 1, d[i, j]) } print "" } }'
}

function defaultFormat() {
  awk 'BEGIN { print "Namespace PVC 1K-blocks Used Available Use%" } '\
'{$3 = $3/1024; $4 = $4/1024; $5 = $5/1024; $6 = sprintf("%.0f%%",$6); print $0}'
}

function humanFormat() {
  awk 'BEGIN { print "Namespace PVC Size Used Avail Use%" } '\
'{$6 = sprintf("%.0f%%",$6); printf("%s %s ", $1, $2); system(sprintf("numfmt --to=iec %s %s %s | sed '\''N;N;s/\\n/ /g'\'' | tr -d \\\\n", $3, $4, $5)); print " " $6 }'
}

function format() {
  jq -r '.[] | "\(.namespace) \(.name) \(.capacityBytes) \(.usedBytes) \(.availableBytes) \(.percentageUsed)"' |
    $format | column
}

if [ "$1" == "-h" ]; then
  format=humanFormat
else
  format=defaultFormat
fi

NAMESPACE_FILTER="$1"

for node in $(getNodes); do
  kubectl get --raw $NODESAPI/$node/proxy/stats/summary
done | getPVCs | jq --arg ns "$NAMESPACE_FILTER" 'if $ns == "" then . else map(select(.namespace == $ns)) end' | format
