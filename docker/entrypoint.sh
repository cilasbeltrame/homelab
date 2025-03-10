#!/bin/bash
set -e

# Check if GH_RUNNER_TOKEN and GH_REPO_URL are provided
if [[ -z "$GH_RUNNER_TOKEN" || -z "$GH_REPO_URL" ]]; then
  echo "Error: GH_RUNNER_TOKEN and GH_REPO_URL environment variables are not set"
  echo "Please run the container with: docker run -e GH_REPO_URL=<your-repo-url> -e GH_RUNNER_TOKEN=<your-token> ..."
  exit 1
fi

# Configure the runner if not already configured
if [ ! -f ".runner" ]; then
  ./config.sh --url "$GH_REPO_URL" --token "$GH_RUNNER_TOKEN" --unattended
fi

# Start the runner
exec ./run.sh "$@" 
