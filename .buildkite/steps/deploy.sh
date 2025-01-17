#!/usr/bin/env ash

set -euo pipefail

echo --- :hammer: Installing tools
apk add helm yq skopeo git --quiet --no-progress

tag=$(git describe)
version=$(echo "$tag" | sed 's/v//')
temp_agent_image=$(buildkite-agent meta-data get "agent-image")
agent_image="ghcr.io/buildkite/agent-stack-k8s/agent:${tag}"
controller_image=$(buildkite-agent meta-data get "controller-image")

echo --- :helm: Help upgrade
helm upgrade agent-stack-k8s ${helm_image}/agent-stack-k8s \
    --version ${version} \
    --namespace buildkite \
    --install \
    --create-namespace \
    --wait \
    --set config.org="$BUILDKITE_ORGANIZATION_SLUG" \
    --set agentToken="$BUILDKITE_AGENT_TOKEN" \
    --set graphqlToken="$BUILDKITE_TOKEN" \
    --set config.image="$agent_image" \
    --set config.debug=true \
    --set config.profiler-address=localhost:6060
