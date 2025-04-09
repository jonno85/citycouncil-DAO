#!/bin/bash

# Load environment variables
source .env

# Ensure required environment variables are set
if [ -z "$SEPOLIA_RPC_URL" ] || [ -z "$SEPOLIA_PRIVATE_KEY" ] || [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Error: Missing required environment variables"
    echo "Please ensure SEPOLIA_RPC_URL, SEPOLIA_PRIVATE_KEY, and ETHERSCAN_API_KEY are set in .env"
    exit 1
fi

# Deploy to Sepolia
echo "Deploying to Sepolia..."
forge script script/DeploySepolia.s.sol:DeploySepolia \
    --rpc-url $SEPOLIA_RPC_URL \
    --broadcast \
    --verify \
    -vvvv

# Check if deployment was successful
if [ $? -eq 0 ]; then
    echo "Deployment successful!"
    echo "Contract addresses saved to deployment.txt"
    
    # Wait for verification
    echo "Waiting for verification..."
    sleep 30
    
    # Display deployment info
    cat deployment.txt
else
    echo "Deployment failed!"
fi