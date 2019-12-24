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

---

## Contract Admin

## Pause contract
Admin only: Pauses updating of contract state for registry whitelist, content registry and filling of orders. Does not stop reads or content id validation in `isContentIdRegisteredToCaller()` used by our ERC-721s.

#### pause()
#### unpause()

## Transfer Ownership

#### transferOwnership()
* @param `newOwner`: Address to transfer ownership of contract to

---

## Registry Admin: Write Operations
The following assumes you're querying from truffle console.
```
> Whitelist.deployed().then(inst => { wi = inst })
```
`wi` = whitelist instance

#### adminUpdate()
Admin: Add/remove address to whitelist, map it to contentId.
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `contentId`: UTF8 encoded Microsponsors contentId (see utils.js)
* @param `isApproved`: isWhitelisted status boolean for address.
```
wi.adminUpdate(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "dns%3Afoo.com",
  true)
```
The `contentId` is designed to be pretty flexible in this contract (just a simple string) to allow for maximum forward-compatibility. Details on format [here](https://github.com/microsponsors/utils.js#contentid).

#### adminUpdateWithReferrer()
Admin: Same params as `adminUpdate` with one additional, below:
Is pausable.
* @param `referrer`: the address referring the target, only if `isWhitelisted`

#### adminUpdateRegistrantToReferrer()
Admin: Update the `registrantToReferrer` mapping.
Only if target has registered (whitelist status does not matter) and referrer `isWhitelisted`.
Is pausable.
* @param `target`: the registrant, regardless of their `isWhitelisted` status.
* @param `referrer`: the address referring the target, only if `isWhitelisted`

#### adminUpdateWhitelistStatus()
Admin: Add or remove address from whitelist (set isWhitelisted to false).
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `isApproved`: isWhitelisted status boolean for address.
```
wi.adminUpdateWhitelistStatus(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  false
);
```

#### adminRemoveContentIdFromAddress()
Is pausable.
* @param `target`: Address to remove content id from.
* @param `contentId`: Content id to remove.
```
wi.adminRemoveContentIdFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "dns%3Afoo.com"
);
```

#### removeContentIdFromAddress()
Valid whitelisted address can remove its own content id.
Is pausable.
* @param `contentId`: Content id to remove.
```
wi.removeContentIdFromAddress("dns%3Afoo.com");
```

#### adminRemoveAllContentIdsFromAddress()
Admin removes *all* contentIds from a given address.
Is pausable.
@param `target`: Address to remove all content ids from
```
wi.adminRemoveAllContentIdsFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2"
);
```

#### removeAllContentIdsFromAddress()
Valid whitelisted address can remove *all* contentIds from itself.
Is pausable.
@param `target`: Address to remove all content ids from
```
wi.removeAllContentIdsFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2"
);
```

## Registry Admin: Read Operations

#### isWhitelisted()
Check isWhitelisted status boolean for an address.
Returns boolean.
```
> wi.isWhitelisted("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### hasRegistered()
Any address can check if any address has ever registered, regardless of isWhitelisted status of either.
Returns boolean.
```
> wi.hasRegistered("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### registantTimestamp()
Any address can check the `block.timestamp` of when a registrant was registered, regardless of `isWhitelisted` status.
```
> wi.registrantTimestamp("0xc835cf67962948128157de5ca5b55a4e75f572d2");
```

#### registrantToReferrer()
Any address can get the address that referred a registrant, regardless of `isWhitelisted` status of either.
```
> wi.registrantToReferrer("0xc835cf67962948128157de5ca5b55a4e75f572d2");
```

#### adminGetRegistrantCount()
Admin: Get number of addresses that have ever registered, regardless of isWhitelisted status.
Returns Big Number.
```
> wi.adminGetRegistrantCount()
```

#### adminGetRegistrantByIndex()
Admin: Return registrant address by index (integer), regardless of isWhitelisted status.
* @param `index` represents the slot in public `registrants` array.
Returns error if index does not exist.
```
> wi.adminGetRegistrantByIndex(0)
```

#### adminGetAddressByContentId()
Admin: Get valid whitelist address mapped to a contentId.
* @param `contentId`
```
wi.adminGetAddressByContentId("dns%3Afoo.com")
```

#### adminGetContentIdsByAddress()
Admin: Get the contentId mapped to any address, regardless of whitelist status.
```
wi.adminGetContentIdByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### getContentIdsByAddress()
Any address can get the contentIds mapped to a valid whitelisted address.
```
wi.getContentIdsByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### isContentIdRegisteredToCaller()
Valid whitelisted address confirms registration of its own single content id.
Uses `tx.origin` (vs `msg.sender`) because this function will be called by the Microsponsors ERC-721 contract during the token minting process to confirm that the calling address has the right to mint tokens against a contentId.
* @param `contentId`: UTF8 encoded Microsponsors SRN (see utils.js lib).
```
wi.isContentIdRegisteredToCaller("dns%3Afoo.com")
```

