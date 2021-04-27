#!/usr/bin/env bats

load '../stub'

# Uncomment to enable stub debug output:
# export MYCOMMAND_STUB_DEBUG=/dev/tty

@test "Stub a single command with basic arguments" {
  stub mycommand "llamas : echo running llamas"

  run mycommand llamas

  [ "$status" -eq 0 ]
  [[ "$output" == *"running llamas"* ]]

  unstub mycommand
}

@test "Stub a command with multiple invocations" {
  stub mycommand \
    "llamas : echo running llamas" \
    "alpacas : echo running alpacas"

  run bash -c "mycommand llamas && mycommand alpacas"

  [ "$status" -eq 0 ]
  [[ "$output" == *"running llamas"* ]]
  [[ "$output" == *"running alpacas"* ]]

  unstub mycommand
}

@test "Invoke a stub multiple times" {
  skip "Broken, and not sure why"
  stub mycommand "llamas : echo running llamas"

  run bash -c "mycommand llamas && mycommand llamas"

  unstub mycommand
}

@test "Stub a single command with quoted strings" {
  stub mycommand "llamas '' 'always llamas' : echo running llamas"

  run mycommand llamas '' always\ llamas

  [ "$status" -eq 0 ]
  [[ "$output" == *"running llamas"* ]]

  unstub mycommand
}

@test "Stub a command with an error exit status" {
  stub mycommand "llamas : exit 1"

  run mycommand llamas

  [[ "$status" == '1' ]]

  unstub mycommand
}

function helper_function() {
  echo "the real helper_function()"
}

function function_under_test() {
  echo "The result is from $(helper_function)"
}

@test "Stubbing a helper function next the the one under test" {
  stub helper_function " : echo 'the stubbed-in mock helper_function()'"

  result=$(function_under_test)
  [[ "$result" == 'The result is from the stubbed-in mock helper_function()' ]]

  unstub helper_function
}
