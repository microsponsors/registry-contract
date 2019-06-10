# Microsponsors Proof-of-Content Registry Contract

On-chain registry that maps Microsponsors user content to their Ethereum address. Functionally, this is a whitelist that will be integrated into our onboarding flow. It will ensure that only verified users are transacting.

Boilerplate source code is more or less copied/ compiled from [0x's Whitelist.sol example contract](https://github.com/0xProject/0x-monorepo/blob/development/contracts/exchange/contracts/examples/Whitelist.sol)


## Build & Compile:
`$ npm install`
`$ truffle compile`

* Note that dependency versions are locked for safety/ consistency. Updates to package dependencies will happen manually on a case-by-case basis.


## Development Notes
How this was put together:
```
$ truffle init
$ npm install @0x/contracts-exchange --save`
$ truffle compile
```
...per instructions [here](https://github.com/0xProject/0x-monorepo/tree/development/contracts/exchange)

