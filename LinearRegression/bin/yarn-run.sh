#!/bin/bash
#==Linear Regression== 
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

echo "========== running LinearRegression benchmark on YARN =========="
# configure
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"



# path check

SIZE=`${DU} -s ${INPUT_HDFS} | awk '{ print $1 }'`

#JAR="${DIR}/target/scala-2.10/LinearRegression-app_2.10-1.0.jar"
CLASS="LinearRegression.src.main.java.LinearRegressionApp"
OPTION=" ${INPUT_HDFS} ${OUTPUT_HDFS} ${MAX_ITERATION} "

JAR="${DIR}/target/LinearRegression-project-1.0.jar"

nexe=3
dmem=4g
emem=2g
ecore=1
YARN_OPT="--num-executors $nexe --driver-memory $dmem --exectuor-memory $emem --executor-cores $ecore"

for((i=0;i<${NUM_TRIALS};i++)); do
	
	${RM} -r ${OUTPUT_HDFS}
	purge_data "${MC_LIST}"	
	START_TS=get_start_ts
	START_TIME=`timestamp`
	exec ${SPARK_HOME}/bin/spark-submit --class $CLASS --master yarn-cluster ${YARN_OPT} --conf spark.storage.memoryFraction=${memoryFraction} $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/LinearRegression_run_${START_TS}.dat
	END_TIME=`timestamp`
	gen_report "LinearRegression" ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} >> ${BENCH_REPORT}
	print_config ${BENCH_REPORT}
done
exit 0


#if [ $COMPRESS -eq 1 ]; then
#    COMPRESS_OPT="-Dmapred.output.compress=true
#    -Dmapred.output.compression.codec=$COMPRESS_CODEC"
#else
#    COMPRESS_OPT="-Dmapred.output.compress=false"
#fi
