#!/bin/bash
URL="https://192.168.1.194/"
CLIENTCERT="client.crt"
CLIENTKEY="client.key"
CACERT="ca.crt"
TOTALREQUEST=100
declare -a LATENCIES
pidstat -r -u 1 > cpumem.log &
PIDSTAT_PID=$!
echo "start"
START_TIME=$(date +%s%N)
for((i=1;i<TOTALREQUEST;i++)); do
	LATENCY=$(curl --cert $CLIENTCERT --key $CLIENTKEY --cacert $CACERT -s -o /dev/null -w "%{time_appconnect}" $URL)
	LATENCIES+=("$LATENCY")
done
echo "curls done"
END_TIME=$(date +%s%N)
kill $PIDSTAT_PID
DURATION=$(echo "scale=6; ($END_TIME - $START_TIME) / 1000000000" | bc -l)
THROUGHPUT=$(echo "scale=6; $TOTALREQUEST / $DURATION" | bc -l)
echo "troughtput :$THROUGHPUT"
echo "duration :$DURATION"
printf "%s\n" "${LATENCIES[@]}"> latency.log
TOTAL_LATENCY=0.000
for LAT in "${LATENCIES[@]}"; do
	LAT=$(echo "$LAT" | tr -d '[:space:]')
	TOTAL_LATENCY=$(echo "$TOTAL_LATENCY + $LAT" | bc -l)
done
AVRAGE_LATENCY=$(echo "scaled=6; $TOTAL_LATENCY / $TOTALREQUEST" | bc -l)
echo "total latency: $TOTAL_LATENCY"
echo "avrage latency: $AVRAGE_LATENCY"

SUM_SQ_DIFF=0.000
for LAT in "${LATENCIES[@]}"; do
        LAT=$(echo "$LAT" | tr -d '[:space:]')
	DIFF=$(echo "$LAT - $AVRAGE_LATENCY" | bc -l)
	SQ_DIFF=$(echo "$DIFF * $DIFF" | bc -l)
	SUM_SQ_DIFF=$(echo "$SUM_SQ_DIFF + $SQ_DIFF" | bc -l)
done
echo "$SUM_SQ_DIFF"
VARIANCE=$(echo "scaled=6; $SUM_SQ_DIFF /  ($TOTALREQUEST - 1)"| bc -l)
echo "$VARIANCE"

tail -n 10 cpumem.log
