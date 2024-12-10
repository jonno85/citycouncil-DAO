# City Council DAO Smart Contract

A decentralized autonomous organization (DAO) smart contract system designed to manage city council operations, including meeting scheduling, political objective tracking, and council member voting.

## Features

### Council Management
- Governance admin can add and remove council members
- Protected admin privileges for critical operations
- Track council member status and participation

### Political Objectives
- Council members can propose political objectives
- Each objective includes title and description
- Objectives can be activated/deactivated
- Track objective status and proposer

### Meeting Management
- Schedule council meetings with specific times
- Maintain a queue of objectives for each meeting
- Track meeting attendance and status
- Add/remove objectives from meeting queues

### Voting System
- Council members can vote on objectives (YES/NO/ABSTAIN)
- Configurable voting duration
- Automatic vote tallying
- Majority-based decision making
- Track voting results and participation

## Smart Contracts

- `CityCouncilDAO.sol`: Main contract handling council operations and member management
- `CityCouncilMeetingQueue.sol`: Manages meeting scheduling and objective queues
- `VotingFunction.sol`: Handles voting operations and result tracking

## Development

Built using Foundry, a blazing fast, portable, and modular toolkit for Ethereum application development.

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.28

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd city-council-dao

# Install dependencies
forge install

# Build
forge build

# Run tests
forge test
```

### Deployment

1. Set up your environment variables:
```bash
export PRIVATE_KEY=<your-private-key>
```

2. Deploy the contract:
```bash
forge script script/CityCouncilDAO.s.sol:CityCouncilDAOScript --rpc-url <your_rpc_url> --broadcast
```

## Testing

Comprehensive test suite available in `test/CityCouncilDAO.t.sol`. Run specific tests with:

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testFunctionName

# Run tests with verbose output
forge test -vvvv
```

## License

MIT License