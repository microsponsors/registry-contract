# Proof-of-Content Registry Contract

On-chain registry that maps a users' Ethereum address to an isWhitelisted boolean and a contentId. Bids and fills will be validated by this contract.

Boilerplate source code is more or less copy-pasted from [0x's Whitelist.sol example contract](https://github.com/0xProject/0x-monorepo/blob/development/contracts/exchange/contracts/examples/Whitelist.sol)


## Install, Compile & Deploy

Install dependencies: `$ npm install`

Start Ganache in another terminal: `$ ganache-cli -p 8545`

Compile: `$ npm run compile`

Note that in /migrations/2_deploy_contracts.js, the second argument to `.deploy()` must be the 0x Exchange contract that the Whitelist forwards the order to after whitelist validation.

Compile & Deploy in one step: `$ npm run deploy`

* Note: dependency versions are locked for safety/ consistency. Updates to package dependencies will happen manually on a case-by-case basis.

### Versioning
This stack seems to be sensitive to versioning, so capturing details here:

* truffle v5.0.21
* ganache-cli v6.4.3
* solc compiler 0.5.5, specified in truffle-config.js

### Linter
Install [solhint](https://www.npmjs.com/package/solhint) globally and run the linter:
```
$ npm install -g solhint
$ npm run lint
```


## Scenarios
Start ganache in one terminal, truffle console in another.
```
$ ganache-cli -p 8545
$ truffle console --network development
```

### Manage Whitelist
```
> Whitelist.deployed().then(inst => { wi = inst })
```
`wi` = whitelist instance

### adminUpdateWhitelist()
Admin: Add/remove address to whitelist, map it to contentId
* @param target: Address to add or remove from whitelist.
* @param contentId: Hex-encoded, Ex: web3.utils.utf8ToHex('foo.com')
* @param isApproved: isWhitelisted boolean status for address.
Set 3rd param to `false` to remove address from whitelist.
```
wi.adminUpdateWhitelist(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "0x666f6f2e636f6d",
  true)
```

### adminGetAddressByContentId()
Admin: Get valid whitelist address mapped to a contentId
* @param contentId: Hex-encoded. Ex: web3.toHex('foo.com')
```
wi.adminGetAddressByContentId("0x666f6f2e636f6d")
```

### adminGetDomainByAddress()
Admin: Get the contentId mapped to the valid whitelist address
Handle hex-encoded return value: `web3.toUtf8(<return value>)`
```
wi.adminGetDomainByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

### getContentIdByAddress()
Get contentId mapping for valid whitelist address
Only if msg.sender is asking for own mapping
```
wi.getDomainByAddress({from: "0xc835cf67962948128157de5ca5b55a4e75f572d2"})
```

### isWhitelisted()
Check if address is whitelisted
```
> wi.isWhitelisted("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```


## Dev Notes
How this was put together:
```
$ truffle init
$ npm install @0x/contracts-exchange --save`
$ truffle compile
$ truffle migrate --network development
```
...per instructions [here](https://github.com/0xProject/0x-monorepo/tree/development/contracts/exchange)
