# MintyBurny

[![Coverage Status](https://coveralls.io/repos/github/BillSchumacher/MintyBurny/badge.svg?branch=main)](https://coveralls.io/github/BillSchumacher/MintyBurny?branch=main)

A Scaffold-ETH 2 project implementing minting and burning ERC20 extensions.

## Deployed Contracts

### MintyBurnyRegistry

Can be used to track minting and burning of ERC20 tokens, external to the contract.

Currently deployed at:

- MainNet: https://etherscan.io/address/0x4fbC1714767861e4293dDc4764C2e68fBe1f3856
- TestNet: https://sepolia.etherscan.io/address/0xad20652a7e2650128EDFd7135dC2A2B219B0b777

Used by Hot Dog (HOTDOG) and Chilly Dog (BURRRR) tokens.

### Hot Dog (HOTDOG)

An ERC20 token, implements Proof Of Burn with a target of the popular Shiba Inu (SHIB) token.

Anyone can mint HOTDOG tokens by paying the mint fee. The mint fee increases with each mint.

The number of tokens minted is determined by the number of SHIB tokens burned since the last mint.

50% of the last delta of last burned SHIB tokens are minted as HOTDOG tokens.

Currently deployed at:

- MainNet: https://etherscan.io/address/0x787D961F3DE4FfA402a4A2a0bDf35E1B85E03cC5
- TestNet: https://sepolia.etherscan.io/address/0x497498747d40d1D642bd3a891525fD72309EB320

- UniSwap: https://app.uniswap.org/pools/702714

This contract is used to demonstrate the ERC20ProofOfBurn extension.

About the name, when our dogs come in from sunning themselves on a hot day, they are warm to the touch, and we call them Hot Dogs.

This also works well with the concept of burning SHIB tokens. 

Hot Dog is dedicated to our first dog, a rescue named Sarge. His black coat made him especially warm, he was a very good dog.

### Chilly Dog (BRRRR)

An ERC20 token, implements Proof Of Mint with a target of the Hot Dog (HOTDOG) token.

Anyone can mint BRRRR tokens by paying the mint fee. The mint fee increases with each mint.

The number of tokens minted is determined by the number of HOTDOG tokens minted since the last mint.

50% of the last delta of last minted HOTDOG tokens are minted as BRRRR tokens.

Currently deployed at:

- MainNet: https://etherscan.io/address/0xeFfC85182c8fB93526052ce888179CE1A78594c7
- TestNet: https://sepolia.etherscan.io/address/0x44b0328B9b7Bee32D96457f2Afc3e0816F6f7168
- UniSwap: https://app.uniswap.org/pools/703584

This contract is used to demonstrate the ERC20ProofOfMint extension.

About the name, when our dogs come in on a cold day, they are cold to the touch, and we call them Chilly Dogs.

Chilly Dog is dedicated to our puppy, Prince Charles an Old English Sheepdog. 

Sadly, he passed away recently at 8 years old. He was a very loving, smart and loyal dog.



## Rewards

### Hot Dog (HOTDOG)

Once the AirDrop contract is deployed, the first x addresses to mint and the last x addresses to mint will receive an AirDrop of HOTDOG tokens.

This will be triggerable by anyone after a fixed period of time yet to be determined, distributing x percent of the amount in the AirDrop contract.

The initial x% of excessive minted tokens will be transferred to the AirDrop contract for distribution.

The rest will be used to supply liquidity on Uniswap.

### Chilly Dog (BRRRR)

Once the AirDrop contract is deployed, the first x addresses to mint and the last x addresses to mint will receive an AirDrop of BRRRR tokens.

This will be triggerable by anyone after a fixed period of time yet to be determined, distributing x percent of the amount in the AirDrop contract.

The initial x% of excessive minted tokens will be transferred to the AirDrop contract for distribution.

The rest will be used to supply liquidity on Uniswap.


## Mint Fees

Initially, the mint fee is 0.01 ETH. This is to prevent spamming of the mint function.

Mint fees will be used to:

* Deploy AirDrop contract
* Deploy ProofOfMinter/Burner contract(s).
* Supply liquidity on Uniswap and maybe other exchanges.
* Pay for gas fees

If an abundance of mint fees are collected and liquidity is not needed maybe we can tackle some stretch goals:

* Build housing for the homeless
* Feed the hungry
* Build animal shelters
* Help ERCOT get their act together with some Tesla megapacks.
* Provide solar power with grid ties.
* Build desalination plants.
* Build a space elevator.
* Build a moon base.
* Build a Mars base.
* Make a warp drive.
* Build a Dyson sphere.

## Extensions

I'll update this or move it to a new file a bit later.

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

## Motivation

I wanted to create a project that would allow me to learn more about Solidity and the Ethereum blockchain.

## Random Advice

Deploying using a Ledger wallet, using foundry is not intuitive. 

I started with OpenZeppelin's Defender, but it was too expensive for my needs.

The deployment scripts are not well documented, and the error messages are not helpful.

I eventually figured it out:

`
forge create --from 0x... --ledger --chain sepolia --rpc-url ${1:-sepolia} --mnemonic-index x --constructor-args  {non-abi encoded args here, space separated} --etherscan-api-key demo contracts/YourContract.sol:YourContract
`

From should be the wallet address you want to deploy from. If you get a message about insufficient funds change the mnemonic-index and verify you have the funds.

Change the chain to the chain and rpc-url you want to deploy to.

Address array constructor arguments should be surrounded by quotes.

Don't wrap args in brackets, that's just to show you where the args go.

Verifying a contract deployed via defender can be done like this:

`
forge verify-contract 0xeFfC85182c8fB93526052ce888179CE1A78594c7 contracts/token/ChillyDog.sol:ChillyDog --optimizer-runs 200 --watch --compiler-version 0.8.25 --constructor-args 0000000000000000000000004fbc1714767861e4293ddc4764c2e68fbe1f385600000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000787d961f3de4ffa402a4a2a0bdf35e1b85e03cc5
`

Easiest way to get the constructor arguments is to look at the transaction on etherscan and copy it, it's also visible when you go to verify on etherscan.

Run the forge commands from the packages/foundry directory.

If you want to utilize the mint and burn registry extensions it makes more economic sense to use the MintyBurnyRegistry contract already deployed on MainNet or TestNet.

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
