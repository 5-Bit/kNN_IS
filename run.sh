#! /bin/bash
pushd /home/sparky/knn/kNN_IS
if [ "$1" == "-b" ] || [ "$1" == "--build" ] || [ ! -f target/kNN_IS-2.0.jar ]; then
  echo "Building kNN_IS";
  ./build.sh
fi

if [ -z "${SPARK_HOME}" ]; then
  SPARK_HOME=/usr/local/bin/spark-2.0.0-bin-hadoop2.7
fi

. "${SPARK_HOME}/sbin/stop-master.sh"
. "${SPARK_HOME}/sbin/start-master.sh"

NUM_CORES=1
KEEL_HEADER=/home/sparky/knn/Poker/poker-headers.txt
TRAINING_SET=/home/sparky/knn/Poker/poker-10-cross-validation/poker-10-1tra.dat
TEST_SET=/home/sparky/knn/Poker/poker-10-cross-validation/poker-10-1tst.dat
NUM_NEIGHBORS=10
NUM_MAPS=1
NUM_REDUCERS=1
NUM_ITERATIONS=10
PATH_OUTPUT='/home/sparky/output/poker/out.dat'
MAX_GB_NODE_MEM='0.25'

# This is in the path
spark-submit --master "local"\
 --executor-memory "480m"\
 --total-executor-cores "1"\
 --class org.apache.spark.run.runkNN_IS target/kNN_IS-2.0.jar\
 "$KEEL_HEADER"\
 "$TRAINING_SET"\
 "$TEST_SET"\
 "$NUM_NEIGHBORS"\
 "$NUM_MAPS"\
 "$NUM_REDUCERS"\
 "$NUM_ITERATIONS"\
 "$PATH_OUTPUT"\
 ["$MAX_GB_NODE_MEM"]\
 "mllib" # Can be one of [ "mllib", "ml" ], I think

popd
