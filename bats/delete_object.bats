#!/usr/bin/env bats

load handling_conf_files.bash
load globals.bash
load cleanup-object-storage.bash
load_lib bats-support
load_lib bats-assert

function setup_file() {
    store_config_files
    ensureTestConfig
    deleteCache
}

function teardown_file() {
    restore_config_files
}

@test 'delete  object : ok ' {

  if [ ${INT_ENVIRONMENT} == 'test' ]; then
    skip "Skip: test env has no CMS backend"
  fi

  deleteObjectStorageIfExisting "EU"
  sleep 5
  run ./cntb create objectStorage --region "EU" --totalPurchasedSpaceTB 1 --scalingState "enabled" --scalingLimitTB 1
  assert_success

  run ./cntb create bucket EU ${TEST_SUFFIX}
  assert_success

  run ./cntb create object --region "EU" --bucket ${TEST_SUFFIX} --prefix '/test/${TEST_SUFFIX}'
  assert_success

  run ./cntb delete object --region "EU" --bucket ${TEST_SUFFIX} --path '/test/${TEST_SUFFIX}'
  assert_success

  deleteObjectStorageIfExisting "EU"
}

@test 'delete object : ok : delete file' {
  if [ ${INT_ENVIRONMENT} == 'test' ]; then
      skip "Skip: test env has no CMS backend"
  fi

  deleteObjectStorageIfExisting "EU"
  sleep 5
  run ./cntb create objectStorage --region "EU" --totalPurchasedSpaceTB 1 --scalingState "enabled" --scalingLimitTB 1
  assert_success

  run ./cntb create bucket EU ${TEST_SUFFIX}
  assert_success

  run ./cntb create object --region "EU" --bucket ${TEST_SUFFIX} --prefix '/test/${TEST_SUFFIX}' --path "go.sum"
  assert_success

  run ./cntb delete object --region "EU" --bucket ${TEST_SUFFIX} --path '/test/${TEST_SUFFIX}/go.sum'
  assert_success

  deleteObjectStorageIfExisting "EU"
}



@test 'delete object : nok : missing argument' {
  if [ ${INT_ENVIRONMENT} == 'test' ]; then
      skip "Skip: test env has no CMS backend"
  fi

  run ./cntb delete object  --bucket ${TEST_SUFFIX} --path '/test/${TEST_SUFFIX}' 
  assert_failure
  assert_output --partial 'Argument region is empty.'

  run ./cntb delete object --region "EU"  --path '/test/${TEST_SUFFIX}' 
  assert_failure
  assert_output --partial 'Argument bucket is empty.'

  run ./cntb delete object --region "EU" --bucket ${TEST_SUFFIX} 
  assert_failure
  assert_output --partial 'Argument path is empty.'
}


