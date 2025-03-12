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

# Configure SSH pub key from docker host
if [[ ! -z "$GH_RUNNER_SSH_KEY" && ! -z "$DOCKER_HOST_SSH" ]]; then
  mkdir -p /runner/.ssh
  echo "$GH_RUNNER_SSH_KEY" > /runner/.ssh/id_rsa
  chmod 600 /runner/.ssh/id_rsa
  # Start SSH agent in the background
  eval "$(ssh-agent -s)"
  # Add SSH key to agent
  ssh-add /runner/.ssh/id_rsa

  echo "Host docker-host
  HostName $DOCKER_HOST_SSH
  User ${DOCKER_HOST_USER:-root}
  IdentityFile /runner/.ssh/id_rsa
  StrictHostKeyChecking no
  PasswordAuthentication no" > /runner/.ssh/config
  chmod 600 /runner/.ssh/config
fi

# Start the runner
exec ./run.sh "$@" 
