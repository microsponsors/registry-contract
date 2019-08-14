# Proof-of-Content Registry Contract

[WIP] On-chain registry that maps a users' Ethereum `address` to an `isWhitelisted` boolean and any `contentId` they wish to associate with that address, as defined in our [utils.js library here](https://github.com/microsponsors/utils.js#contentid).

Bids and order fills in the [0x Protocol](https://0x.org) format will be validated by this contract.

Boilerplate Whitelist.sol source code is more or less copy-pasted from [0x's Whitelist.sol example contract](https://github.com/0xProject/0x-monorepo/blob/development/contracts/exchange/contracts/examples/Whitelist.sol)

For doc purposes, things here marked `Admin` refer to the `owner` of this smart contract.


## Install, Compile & Deploy

* Install 0x dependencies: `$ npm install`
* Start Ganache in another terminal: `$ ganache-cli -p 8545`
* Compile: `$ npm run compile`. Deploy to local ganache instance: `$ truffle migrate --network development `
* Or... Compile & Deploy in one step: `$ npm run deploy`

_Note:_ In `/migrations/2_deploy_contracts.js`, the second argument to `.deploy()` must be the 0x Exchange contract that the Whitelist forwards the order to after whitelist validation. Latest [0x smart contract addresses can be found here](https://github.com/0xProject/0x-monorepo/tree/development/packages/contract-addresses).

_Note:_ Dependency versions are locked for safety/ consistency. Updates to package dependencies will happen manually on a case-by-case basis.

#### Versioning
This stack seems to be sensitive to versioning, so capturing details of local setup here:

* truffle v5.0.21
* ganache-cli v6.4.3
* solc compiler 0.5.5, specified in truffle-config.js

#### Linter
Install [solhint](https://www.npmjs.com/package/solhint) globally and run the linter:
```
$ npm install -g solhint
$ npm run lint
```

#### Original Setup
How this repo was originally put together:
```
$ truffle init
$ npm install @0x/contracts-exchange --save`
$ truffle compile
$ truffle migrate --network development
```
...per instructions in [0x Monorepo here](https://github.com/0xProject/0x-monorepo/tree/development/contracts/exchange)


## Running locally
Start ganache in one terminal, truffle console in another.
```
$ ganache-cli -p 8545
$ truffle console --network development
```


## Writes to Whitelist + Content Registry State
```
> Whitelist.deployed().then(inst => { wi = inst })
```
`wi` = whitelist instance

#### adminUpdate()
Admin: Add/remove address to whitelist, map it to contentId.
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `contentId`: Hex-encoded, Ex: web3.utils.utf8ToHex('foo.com')
* @param `isApproved`: isWhitelisted status boolean for address.
```
wi.adminUpdate(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "0x666f6f2e636f6d",
  true)
```
The `contentId` is designed to be pretty flexible in this contract (just a simple string) to allow for maximum forward-compatibility. Details on format [here](https://github.com/microsponsors/utils.js#contentid).

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
  "0x666f6f2e636f6d"
);
```

#### removeContentIdFromAddress()
Valid whitelisted address can remove its own content id.
Is pausable.
* @param `contentId`: Content id to remove.
```
wi.removeContentIdFromAddress("0x666f6f2e636f6d");
```


## Read from Whitelist + Content Registry State

#### isWhitelisted()
Check isWhitelisted status boolean for an address.
Returns boolean.
```
> wi.isWhitelisted("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### hasRegistered()
Check if address has ever registered, regardless of isWhitelisted status.
Returns boolean.
```
> wi.hasRegistered("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### adminGetRegistrantCount()
Get number of addresses that have ever registered, regardless of isWhitelisted status.
Returns Big Number.
```
> wi.adminGetRegistrantCount()
```

#### adminGetRegistrantByIndex()
Return registrant address by index (integer), regardless of isWhitelisted status.
* @param `index` represents the slot in public `registrants` array.
Returns error if index does not exist.
```
> wi.adminGetRegistrantByIndex(0)
```

#### adminGetAddressByContentId()
Admin: Get valid whitelist address mapped to a contentId.
* @param `contentId`: Hex-encoded. Ex: `web3.toHex('foo.com')`
```
wi.adminGetAddressByContentId("0x666f6f2e636f6d")
```

#### adminGetContentIdsByAddress()
Admin: Get the contentId mapped to the valid whitelist address.
Handle hex-encoded return value: `web3.toUtf8(<return value>)`
```
wi.adminGetContentIdByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### getContentIdsByAddress()
Get contentIds for valid whitelist address.
Only if msg.sender is asking for own mappings.
```
wi.getContentIdByAddress({from: "0xc835cf67962948128157de5ca5b55a4e75f572d2"})
```


## 0x Exchange Functions

#### isValidSignature()
Verifies current signer is same as signer of incoming bid or order fill.

#### fillOrderIfWhitelisted()
Is pausable.


## Pause contract
Admin: Pauses updating of contract state for whitelist, content registry and filling of orders.
Does not stop reads or signature validation!

#### pause()
#### unpause()


## Ox orders
Example 0x Protocol `order` object that is submitted as first argument to `fillOrderIfWhitelisted()`:

```javascript
interface Order {
    senderAddress: string;
    // Ethereum address of the Maker
    makerAddress: string;
    // Ethereum address of the Taker. If no address specified, anyone can fill the order.
    takerAddress: string;
    // How many ZRX the Maker will pay as a fee to the relayer
    makerFee: BigNumber;
    // How many ZRX the Taker will pay as a fee to the relayer
    takerFee: BigNumber;
    // The amount of an asset the Maker is offering to exchange
    makerAssetAmount: BigNumber;
    // The amount of an asset the Maker is willing to accept in return
    takerAssetAmount: BigNumber;
    // The identifying data about the asset the Maker is offering
    makerAssetData: string;
    // The identifying data about the asset the Maker is requesting in return
    takerAssetData: string;
    // A salt to guarantee OrderHash uniqueness. Usually a milisecond timestamp of when order was made
    salt: BigNumber;
    // The address of the 0x protocol exchange smart contract
    exchangeAddress: string;
    // The address (user or smart contract) that will receive the fees
    feeRecipientAddress: string;
    // When the order will expire (unix timestamp in seconds)
    expirationTimeSeconds: BigNumber;
}
```
