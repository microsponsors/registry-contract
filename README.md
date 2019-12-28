# Proof-of-Content Registry Contract

On-chain registry that maps a users' Ethereum `address` to an `isWhitelisted` boolean and any `contentId` they wish to associate with that address, as defined in our [utils.js library here](https://github.com/microsponsors/utils.js#contentid).

Also maps a registrant to the address that referred them, plus the timestamp of when they were referred so we can reward the referrer for a period of time.

For doc purposes, things here marked `Admin` refer to the `owner` of this smart contract.


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

