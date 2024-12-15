#!/bin/bash

# Start local testnet (in background)
echo "Starting Anvil..."
anvil &
ANVIL_PID=$!

# Wait for Anvil to start
sleep 2

# Deploy contracts
echo "Deploying contracts..."
forge script script/DeployLocal.s.sol:DeployLocal --fork-url http://localhost:8545 --broadcast

# Interact with contracts
echo "Interacting with contracts..."
forge script script/InteractLocal.s.sol:InteractLocal --fork-url http://localhost:8545 --broadcast

# Kill Anvil
kill $ANVIL_PID