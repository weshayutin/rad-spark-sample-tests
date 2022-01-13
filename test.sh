#!/bin/bash

source $TEST_DIR/common

MY_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)

os::test::junit::declare_suite_start "$MY_SCRIPT"

helloworld() {
  info
  sleep 2
  os::cmd::try_until_text "oc get pod  -n openshift-adp -o yaml" 'ready: true'
  os::cmd::expect_success "set"
  os::cmd::expect_success "pwd"

}

helloworld

os::test::junit::declare_suite_end
