#!/bin/bash

# Store the current directory
current_dir=$(pwd)

is_server_change=$(git diff --cached --name-only | grep -c "app/server")
is_client_change=$(git diff --cached --name-only | grep -c "app/client")

is_merge_commit=$(git rev-parse -q --verify MERGE_HEAD)

if [ "$is_merge_commit" ]; then
  echo "Skipping server and client checks for merge commit"
else
  if [ "$is_server_change" -ge 1 ]; then
    echo "Running Spotless check for server-side code ..."
    cd app/server || exit 1
    if (mvn spotless:check 1> /dev/null && cd "$current_dir") then
      cd "$current_dir"
    else
      echo "Spotless check failed for server-side code, please run mvn spotless:apply"
      exit 1
    fi
  else
    echo "Skipping server side check..."
  fi

  if [ "$is_client_change" -ge 1  ]; then
    echo "Running lint-staged for client-side code ..."
    npx lint-staged --cwd app/client
  else
    echo "Skipping client side check..."
  fi
fi

# Ignore gitleaks task error and continue with the commit
exit 0
