# cpcoin Clarinet Project

This project defines the `cpcoin` fungible token smart contract using [Clarinet](https://github.com/hirosystems/clarinet) for local development, testing, and deployment on the Stacks blockchain.

## Project structure

- `Clarinet.toml` – Clarinet project configuration
- `contracts/` – Clarity smart contracts
  - `cpcoin.clar` – cpcoin fungible token contract
- `tests/` – JavaScript/TypeScript tests for the contracts
- `settings/` – Network configuration files for Mainnet, Testnet, and Devnet

## cpcoin token

`cpcoin` is a simple fungible token contract that:

- Defines a fixed token name, symbol, and decimals
- Tracks balances and total supply
- Allows the contract deployer (admin) to mint and burn tokens
- Allows users to transfer tokens to other principals

All state transitions are protected with appropriate checks and return descriptive error codes.

## Requirements

- Node.js and npm (for running tests)
- [Clarinet](https://docs.hiro.so/clarinet) `>= 3.10.0`

## Getting started

From this project directory (`cpcoin-project`):

```bash
clarinet check
```

This command parses and type-checks all contracts under `contracts/`.

To run the interactive console with your contracts loaded:

```bash
clarinet console
```

To run the test suite (after installing dependencies):

```bash
npm install
npm test
```

## Development workflow

1. Edit `contracts/cpcoin.clar` to adjust token logic or add new entrypoints.
2. Run `clarinet check` frequently while editing.
3. Add or update tests in `tests/` to validate behavior.
4. Use `clarinet console` or `clarinet integrate` to interact with the contract on a local Devnet.

## Running checks

To verify that the contract parses and type-checks correctly, run:

```bash
clarinet check
```

If the command succeeds without errors, the cpcoin contract is syntactically and semantically valid according to Clarinet's analysis.
