# Microsponsors Proof-of-Content Registry Contract

This is the on-chain Registry that maps an Ethereum `address` to:
- an `isWhitelisted` boolean
- the timestamp of the block the account was registered in
- any `contentId` the account wishes to associate with their address, as defined in our utils.js library [here](https://github.com/microsponsors/utils.js#contentid). All `contentId`s are verified in order to help prevent fraud/ impersonation/ spamming when Minting [MSPT](https://github.com/microsponsors/erc-721) tokens.
- (optionally) records which address acted as the `referrer` for each registered address so we can reward them later

For doc purposes, things marked `Admin` refer to the `owner` of this smart contract.

## Minting & Transfer Restrictions
Note that there *are* transfer restrictions on Microsponsors [MSPT](https://github.com/microsponsors/erc-721) time slot tokens that are enforced by this registry, to satisfy the following business requirements:

1. All Minters ("Creators") must be validated in our Proof-of-Content Registry to help eliminate fraud/ impersonation/ spamming.
2. Microsponsors ERC-721s (NFTs) give Minters the option to disable token resale to third-parties, to help ensure that their time slots aren't sold to anyone they do not wish to transact with. This is useful for certain use-cases, i.e. Creators who want to carefully choose which organizations they wish to work with.

## Path to Federation
The long-term plan is for Microsponsors to Federate (think: DAOs, game studios, media orgs, agencies, consultants, freelancers, etc). We plan to Federate so that other organizations can implement their own rules and logic around Registration, token minting, selling and re-selling.

_In this way, Microsponsors becomes an open protocol utility rather than simply a standalone dapp. Other organizations can spin up their own marketplaces, applications and front-ends, and use Microsponsors tokens as a composable building block that can be layered in with their own blockchain apps._

The functions in this contract that will enable federation as well as govern transfer restrictions are below; they are currently called directly by Microsponsors' ERC-721 token contract. To federate, we will create another smart contract called the Federation Relay that keeps track of each Federation members' Registry contract addresses (this first Registry contract will become just one instance of a Microsponsors Registry among many).

During `mint()` and `transferFrom()` calls the Federation Relay will forward the following function calls to the appropriate registry contract according to its `federationId`:

```
function isContentIdRegisteredToCaller(uint32 federationId, string memory contentId) public view returns(bool);
function isMinter(uint32 federationId, address account) public view returns (bool);
function isAuthorizedTransferFrom(uint32 federationId, address from, address to, uint256 tokenId, address minter, address owner) public view returns(bool);

```

Each Federation member can then implement its own Registry with its own Whitelists and Transfer Restrictions.

---

## Smart Contract Addresses/ Deployments
See [DEPLOYS.md](DEPLOYS.md)

## See All Contract Methods
See [test/TEST_CASES.md](test/TEST_CASES.md)

---

## Install, Develop, Deploy

#### Install
* Install 0x dependencies: `$ npm install`

_Note:_ Dependency versions are locked for safety/ consistency. Updates to package dependencies will happen manually on a case-by-case basis.

#### Lint
Install [solhint](https://www.npmjs.com/package/solhint) globally and run the linter:
```
$ npm install -g solhint
$ npm run lint
```

#### Local Deploy
See `/migrations/2_deploy_contracts.js` and `./truffle-config.js`

* Start Ganache in another terminal: `$ ganache-cli -p 8545`
* Compile: `$ npm run compile`. Rebuilds `/build` dir.
* Deploy to local ganache instance: `$ truffle migrate --network development `
* Or... Compile & Deploy in one step: `$ npm run deploy`

#### Flatten for Remix Deploy
* `npm run flatten`

#### Versioning
This stack seems to be sensitive to versioning, so capturing details of local setup here:

* truffle v5.0.21
* ganache-cli v6.4.3
* solc compiler 0.5.5, specified in truffle-config.js
* for Remix: use compiler 0.5.5 + EVM version `byzantium`

#### Git tag + DEPLOYS.md
Each public network deployment is git tagged (starting with `v0.1`) and recorded in [DEPLOYS.md](DEPLOYS.md)

---

#### Note on ABIEncoderV2
This contract is using `pragma experimental ABIEncoderV2`. Because both [0x](https://0x.org) and [dydx](https://dydx.exchange/) have been using it for many months, and critical bugs were fixed as far back as Solidity 0.5.4, we think its probably ok to use in production. Remarks on this [from the dydx team via Open Zeppelin blog](https://blog.openzeppelin.com/solo-margin-protocol-audit-30ac2aaf6b10/).

---

#### Original Setup
Just for posterity: how this repo was originally put together:
```
$ truffle init
$ npm install @0x/contracts-exchange --save`
$ truffle compile
$ truffle migrate --network development
```
...per instructions in [0x Monorepo here](https://github.com/0xProject/0x-monorepo/tree/development/contracts/exchange)




