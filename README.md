# Microsponsors Proof-of-Content Registry Contract

The on-chain Registry that maps a users' Ethereum `address` to an `isWhitelisted` boolean, the timestamp of the block the account was registered in, and any `contentId` the account wishes to associate with their address, as defined in our utils.js library [here](https://github.com/microsponsors/utils.js#contentid).

The Registry also records which address acted as the `referrer` for each registered address so we can reward them.

For doc purposes, things here marked `Admin` refer to the `owner` of this smart contract.

## Path to Federation
The long-term plan is to create a path for Microsponsors to federate: encouraging other organizations to create their own exchange front-ends with their own set of granular rules about minting Micropsponsors tokens, selling and re-selling, cross-exchange arbitrage, etc etc.

The functions in this contract that will enable federation are below; they are currently called directly by Microsponsors' ERC-721 token contract. When we are ready to federate, we can create another smart contract that keeps track of partner Registry addresses (this contract will become just one instance of a Microsponsors Registry among many), and forward the follwoing calls to the appropriate partner contract for each token:

```javascript
function isContentIdRegisteredToCaller(string calldata contentId) public view returns(bool);
function isMinter(address account) public view returns (bool);
function isTrader(address account) public view returns(bool);
function isAuthorizedTransferFrom(address from, address to, uint256 tokenId) public view returns(bool);
function isAuthorizedResale(address from, address to, uint256 tokenId) public view returns(bool);
```

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

## How To Use
See `test/TEST_CASES.md`

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




