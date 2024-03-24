# MintyBurny

[![Coverage Status](https://coveralls.io/repos/github/BillSchumacher/MintyBurny/badge.svg?branch=main)](https://coveralls.io/github/BillSchumacher/MintyBurny?branch=main)

A Scaffold-ETH 2 project implementing minting and burning ERC20 extensions.

## Contracts

### ERC20MintRegistry
An abstract contract that tracks the minting of ERC20 tokens.

### ERC20BurnRegistry
An abstract contract that tracks the burning of ERC20 tokens.

### ERC20MintyBurnyErrors
Error definitions.

### ERC20ProofOfBurn
An abstract contract that implements a proof of burn mechanism for ERC20 tokens.

Allows minting of tokens if the target contracts' burn addresses has more burned tokens than the last burned amount.

### ERC20ProofOfBurner
An abstract contract that implements a proof of burn mechanism for ERC20 tokens.

This requires that the target contract implements the ERC20BurnRegistry.

Allows minting of tokens if the target contract's burn registry has more burned tokens than the last burned amount for the sender.

### ERC20ProofOfMint
An abstract contract that implements a proof of mint mechanism for ERC20 tokens.

Allows minting of tokens if the target contract's total supply has more minted tokens than the last minted amount.

### ERC20ProofOfMinter
An abstract contract that implements a proof of mint mechanism for ERC20 tokens.

This requires that the target contract implements the ERC20MintRegistry.

Allows minting of tokens if the target contract's mint registry has more minted tokens than the last minted amount for the sender.

### ERC20MintyBurny
A smart contract implementing ERC20MintRegistry and ERC20BurnRegistry.

### ERC20BurntMintyBurny
An example contract implementing all extensions.

### MintyBurny
An example contract implementing ERC20MintRegistry and ERC20BurnRegistry.


## Requirements

Before you begin, you need to install the following tools:

- [Node (>= v18.17)](https://nodejs.org/en/download/)
- Yarn ([v1](https://classic.yarnpkg.com/en/docs/install/) or [v2+](https://yarnpkg.com/getting-started/install))
- [Git](https://git-scm.com/downloads)

## Quickstart

To get started with Scaffold-ETH 2, follow the steps below:

1. Clone this repo & install dependencies

```
git clone https://github.com/scaffold-eth/scaffold-eth-2.git
cd scaffold-eth-2
yarn install
```

2. Run a local network in the first terminal:

```
yarn chain
```

This command starts a local Ethereum network using Hardhat. The network runs on your local machine and can be used for testing and development. You can customize the network configuration in `hardhat.config.ts`.

3. On a second terminal, deploy the test contract:

```
yarn deploy
```

This command deploys a test smart contract to the local network. The contract is located in `packages/hardhat/contracts` and can be modified to suit your needs. The `yarn deploy` command uses the deploy script located in `packages/hardhat/deploy` to deploy the contract to the network. You can also customize the deploy script.

4. On a third terminal, start your NextJS app:

```
yarn start
```

Visit your app on: `http://localhost:3000`. You can interact with your smart contract using the `Debug Contracts` page. You can tweak the app config in `packages/nextjs/scaffold.config.ts`.

Run smart contract test with `yarn hardhat:test`

- Edit your smart contract `YourContract.sol` in `packages/hardhat/contracts`
- Edit your frontend in `packages/nextjs/pages`
- Edit your deployment scripts in `packages/hardhat/deploy`

## Documentation

Visit our [docs](https://docs.scaffoldeth.io) to learn how to start building with Scaffold-ETH 2.

To know more about its features, check out our [website](https://scaffoldeth.io).

## Contributing to Scaffold-ETH 2

We welcome contributions to Scaffold-ETH 2!

Please see [CONTRIBUTING.MD](https://github.com/scaffold-eth/scaffold-eth-2/blob/main/CONTRIBUTING.md) for more information and guidelines for contributing to Scaffold-ETH 2.
