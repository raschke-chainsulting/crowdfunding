# Simple crowdfunding contract

This repository holds crowdfunding Smart Contracts for launching projects and collecting funds.

## Deployment address

Goerli: [0xe8E7405e983FE210539Bc23218627e16B371100E](https://goerli.etherscan.io/address/0xe8E7405e983FE210539Bc23218627e16B371100E#code)

## Available Scripts

The following scripts are available to interact with this repository. They include compilation, testing, code coverage, documentation generation, deployment and verification of deployed contracts.

### Installing dependencies

To install all required project dependencies run:

```shell
npm install
```

### Compile smart contracts

To compile solidity smart contracts of this repository run:

```shell
npm run compile
```

### Run test cases for smart contract

To execute all test cases located in the _test_ folder run:

```shell
npm run test
```

### Testing code coverage

To get the current code coverage of all test for all solidity files run:

```shell
npm run coverage
```

### Lint smart contracts and typescript files

To lint in solidity and typescript files for errors run:

```shell
npm run lint
```

## Deploy smart contracts

You have to write and run deployment scripts to deploy smart contracts to defined networks. To create deployment scripts check out the [hardhat deployment documentation.](https://hardhat.org/hardhat-runner/docs/guides/deploying)

## Verifying deployed smart contracts

You can easily verifiy deployed smart contract automatically with the hardhat-etherscan plugin. You can verify them by using the CLI directly or writing scripts for each contract. To get more information about contracts verification check out [hardhat-etherscan plugin documentation.](https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-etherscan)

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Goerli.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Goerli node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
npx hardhat run --network goerli scripts/deploy.ts
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS
```
