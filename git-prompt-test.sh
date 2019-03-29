#!/usr/bin/env bash

set -e

readonly PS=$(readlink -f tmp/powershell/pwsh)
readonly SRC_DIR=$(readlink -f .)
readonly POSH_GIT_DIR=$(readlink -f tmp/posh-git)
readonly TEST_SCRATCH_DIR=$(readlink -f tmp/test-scratch)

DIFF_FLAGS=
case "$-i" in
  *i*) if [ -z "$TRAVIS" ]; then
         DIFF_FLAGS=--color=auto 
       fi ;;
  *)   ;;
esac
readonly DIFF_FLAGS

mkdir -p $TEST_SCRATCH_DIR

set +e

# Captures the posh command prompt for posh-git-sh and posh-git.
#
# Input:
# * the working directory is the git repository under test
#
# Output:
# * ../posh-sh
# * ../posh-ps
run_poshes() {
  # Show posh-git-sh PS1. We can't use __posh_git_echo directly because its
  # output includes prompt escape sequences that need to be interpreted by bash.
  bash &> ../posh-sh-unfiltered -i <<EOF
PS1=
source $SRC_DIR/git-prompt.sh
__posh_git_ps1 ===TEST=== ===TEST===
EOF

  # Extract posh-git-sh PS1. Ignore the line where we actually make the call to
  # __posh_git_ps1. The next line, which calls "exit", will have the updated PS1.
  grep -v __posh_git_ps1 < ../posh-sh-unfiltered | sed -n 's/.*===TEST===\(.*\)===TEST===.*/\1/p' > ../posh-sh


  bash > ../posh-ps <<EOF
$PS -Command '& {
Import-Module $POSH_GIT_DIR/src/posh-git.psd1

# Suppress leading space.
\$GitPromptSettings.DefaultPromptWriteStatusFirst = \$true
Write-VcsStatus
}'
EOF
}

# Strips ANSI colors from the input file.
# 
# Input:
# [1] the file
strip_ansi_colors() {
  sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' "$1"
}

# Verifies that the files are equivalent, ignoring ANSI colors.
#
# Inputs:
# [1] $FILE1
# [2] $FILE2
# [3] (optional) label to give to $FILE1 in diff output
#
# Outputs:
# * $FILE1-nocolor
# * $FILE2-nocolor
test_poshes_ignoring_color() {
  local expected=$1
  local actual=$2
  local expected_out
  if [ -z "$3" ]; then
    expected_out=$expected-nocolor
  else
    expected_out=$3-nocolor
  fi
  local actual_out=$actual-nocolor
  strip_ansi_colors "$expected" > "$expected_out"
  strip_ansi_colors "$actual" > "$actual_out"
  diff -u --label="$expected_out" "$expected_out" --label="$actual_out" "$actual_out" $DIFF_FLAGS
}

PASSING=0
PASSING_WARNING=0
FAILING=0
FAILING_WARNING=0

# Tests posh outputs with a specified setup function to create the git
# repository under test. Does not execute the setup function if it already
# ran. In other words, if you change the test setup, you need to delete
# $testcase/git_setup_complete.
#
# Inputs:
# [1] function to set up a git repository test fixture. git init is already
#     called in the working directory
#
# Outputs:
# * modifies PASSING
# * modifies FAILING
run_test() {
  internal_run_test "$1" posh-ps posh-sh
}

# Like run_test, but compares against an expected string instead of against
# posh-ps.
#
# Inputs:
# [1] function to set up the git repository test fixture
# [2] the expected string
run_test_known_diff() {
  internal_run_test "$1" "$2" posh-sh 'overridden-expectation'
}

internal_run_test() {
  local git_setup_fn=$1
  local expected=$2
  local actual=$3
  local expected_alternate_name=$4
  local testcase=$git_setup_fn

  echo '[ RUN  ] '$testcase

  mkdir -p $TEST_SCRATCH_DIR/$testcase/git
  cd $TEST_SCRATCH_DIR/$testcase/git

  if [ ! -f ../git_setup_complete ]; then
    git init &>/dev/null
    $git_setup_fn &>/dev/null
    touch ../git_setup_complete
  fi

  run_poshes

  cd ..

  [ -n "$expected_alternate_name" ]
  local overridden=$?
  if (( $overridden == 0 )); then
    echo -e "\e[33m[ WARN ] expectation override: $expected (while posh-ps is $(strip_ansi_colors posh-ps))\e[0m"
    test_poshes_ignoring_color <(echo $expected) "$actual" "$expected_alternate_name"
  else
    test_poshes_ignoring_color "$expected" "$actual"
  fi
  local t=$?

  if (( $t == 0 )); then
    echo -e "\e[32m[ PASS ] $testcase\e[0m"
    (( PASSING++ ))
    if (( $overridden  == 0 )); then
      (( PASSING_WARNING++ ))
    fi
  else
    echo -e "\e[31m[ FAIL ] $testcase\e[0m"
    (( FAILING++ ))
    if (( $overridden == 0 )); then
      (( FAILING_WARNING++ ))
    fi
  fi
}

empty() {
  :
}
run_test_known_diff empty '[master ?]'

one_file_unstaged() {
  touch stuff
}
run_test_known_diff one_file_unstaged '[master ? +1 ~0 -0]'

one_file_staged() {
  touch stuff
  git add stuff
}
run_test_known_diff one_file_staged '[master ? +1 ~0 -0]'

one_file_staged_with_unstaged_edit() {
  touch stuff
  git add stuff
  echo stuff > stuff
}
run_test_known_diff one_file_staged_with_unstaged_edit '[master ? +1 ~0 -0 | +0 ~1 -0]'

one_file_stashed() {
  touch stuff
  git add .
  git commit -m 'initial commit'

  touch more_stuff
  git add .
  git stash
}
run_test_known_diff one_file_stashed '[master ? (1)]'

# +1 ~1 -1 | +1 ~1 -1
added_edited_deleted_staged_and_unstaged() {
  echo added > added
  echo edited > edited
  echo delete_me_1 > delete_me_1
  echo delete_me_2 > delete_me_2
  git add .
  git commit -m 'stage four files'

  # staged add
  touch newly_added
  git add newly_added
  # unstaged add
  touch unstaged_add

  # staged edit
  echo edit > edited
  git add edited
  # unstaged edit
  echo edited again > edited

  # staged delete
  git rm delete_me_1
  # unstaged delete
  rm delete_me_2
}
run_test_known_diff added_edited_deleted_staged_and_unstaged '[master ? +1 ~1 -1 | +1 ~1 -1]'

# Test summary
if (( $PASSING_WARNING > 0 || $FAILING_WARNING > 0)); then
  echo -e "\e[33mWARN: $PASSING_WARNING tests passed with warnings, $FAILING_WARNING tests failed with warnings\e[0m"
fi

if (( $FAILING > 0 )); then
  echo -e "\e[31mFAIL: $PASSING tests passed, $FAILING tests failed\e[0m"
  exit 1
else
  echo -e "\e[32mPASS: $PASSING tests passed, $FAILING tests failed\e[0m"
  exit 0
fi
