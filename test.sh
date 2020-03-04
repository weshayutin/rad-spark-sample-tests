#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

os::test::junit::declare_suite_start "$MY_SCRIPT"

testCreateCluster1() {
  os::cmd::expect_success_and_text "oc create -f $MY_DIR/manifests/cluster.yaml" '"?my-spark-cluster"? created' && \
  os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=my-spark-cluster-w -o yaml" 'ready: true' && \
  os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=my-spark-cluster-m -o yaml" 'ready: true'
}

testNoPodRestartsOccurred() {
  _CLUSTER=${1}
  os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=${_CLUSTER}-w -o yaml" 'restartCount: 0' && \
  os::cmd::try_until_text "oc get pod -l radanalytics.io/deployment=${_CLUSTER}-m -o yaml" 'restartCount: 0'
}

testScaleCluster() {
  os::cmd::expect_success_and_text 'oc patch sparkcluster my-spark-cluster -p "{\"spec\":{\"worker\": {\"instances\": 1}}}" --type=merge' '"?my-spark-cluster"? patched' || errorLogs
  os::cmd::try_until_text "oc get pods --no-headers -l radanalytics.io/SparkCluster=my-spark-cluster | wc -l" '2'
}

testDeleteCluster() {
  os::cmd::expect_success_and_text 'oc delete SparkCluster my-spark-cluster' '"?my-spark-cluster"? deleted' && \
  os::cmd::try_until_text "oc get pods --no-headers -l radanalytics.io/SparkCluster=my-spark-cluster 2> /dev/null | wc -l" '0'
}

testCreateCluster1
testNoPodRestartsOccurred "my-spark-cluster"
testScaleCluster
testDeleteCluster

os::test::junit::declare_suite_end
