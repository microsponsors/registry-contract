# Test Scenarios

## Local Setup

Start ganache in one terminal locally, then deploy and start truffle console in another:
```
$ ganache-cli -p 8545
$ npm run deploy
$ truffle console --network development
> Registry.deployed().then(inst => { r = inst })
> admin = "<paste 1st address from ganache>"
> account1 = "<paste from ganache>"
> account2 = "<paste from ganache>"
> account3 = "<paste from ganache>"
> contractAddr = "<paste from ganache>"
```
The following test scenarios assume you're querying from truffle console.
`r` = registry instance created when you deployed the Registry (above).


# Test Cases
`Admin` below refers to methods that the the `owner` of the contract (only) has access to.

## Admin: Contract
#### pause()
#### unpause()

## Admin: Ownership
#### owner1()
#### transferOwnership1()
#### owner2()
#### transferOwnership2()

## Admin: Registry Mgmt
#### adminUpdate()
#### adminUpdateWithReferrer()
#### adminUpdateReferrer()
#### adminUpdateWhitelistStatus()
#### adminRemoveContentIdFromAddress()
#### adminRemoveAllContentIdsFromAddress()
#### adminGetAddressByContentId()
#### adminGetContentIdsByAddress()
#### adminGetRegistrantByIndex()

## External/public-facing Functions:
#### isWhitelisted()
#### hasRegistered()
#### getRegistrantCount()
#### getRegistrantByIndex()
#### registantTimestamp()
#### getRegistrantToReferrer()
#### getReferrerToRegistrants()
#### getAddressByContentId()
#### getContentIdsByAddress()
#### removeContentIdFromAddress()
#### removeAllContentIdsFromAddress()

## Integration with MSPT ERC-721 transfer restrictions:
These are the methods that the MSPT smart contract calls to determine if a user action is authorized by this Registry contract:
#### isContentIdRegisteredToCaller()
#### isMinter()
#### isAuthorizedTransferFrom()

---

## Registry Admin

#### adminUpdate()
Admin: Add/remove address to whitelist, map it to contentId.
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `contentId`: UTF8 encoded Microsponsors contentId (see utils.js)
* @param `isApproved`: isWhitelisted status boolean for address.
```javascript
r.adminUpdate(account1, "dns%3Afoo.com", true);
r.adminUpdate(account2, "dns%3Abar.com", true);
r.adminUpdate(account2, "dns%3Abaz.com", true, {from: account2});
// --> should error "ONLY_CONTRACT_OWNER"
r.adminUpdate(account3, "dns%3Azap.com", true);
```
The `contentId` is designed to be pretty flexible in this contract (just a simple string) to allow for maximum forward-compatibility. Details on format [here](https://github.com/microsponsors/utils.js#contentid).

#### adminUpdateWithReferrer()
Admin: Same params as `adminUpdate` with the additional param for `referrer` address. All-or-nothing operation -- will *not* update the `target` address with `contentId` or `isApproved` boolean if something goes wrong with setting the `referrer` (ex: `target` has never registered, or `referrer` !isWhitelisted, or the `target` and the `referrer` are the same). Note that the `target` only needs to have registered (does not need to be whitelisted at time referrer is set).
Is pausable.
* @param `referrer`: the address referring the target, only if `isWhitelisted`
```javascript
r.adminUpdateWithReferrer(account2, "dns%3Abaz.com", true, account1);
```

#### adminUpdateReferrer()
Admin: Update the `registrantToReferrer` and `referrerToRegistrants` mappings.
Only if target has registered (whitelist status does not matter) and referrer `isWhitelisted`.
Is pausable.
* @param `target`: the registrant, regardless of their `isWhitelisted` status.
* @param `referrer`: the address referring the target, only if `isWhitelisted`
```javascript
r.adminUpdateReferrer(account2, account3);
r.adminUpdateReferrer(account2, admin);
// --> should error since admin acct is !isWhitelisted
```

#### adminUpdateWhitelistStatus()
Admin: Add or remove address from whitelist (set isWhitelisted to false).
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `isApproved`: isWhitelisted status boolean for address.
```javascript
r.adminUpdateWhitelistStatus(account1, false);
r.isWhitelisted(account1);
// --> should return false
```

#### adminRemoveContentIdFromAddress()
Is pausable.
* @param `target`: Address to remove content id from.
* @param `contentId`: Content id to remove.
```javascript
r.adminRemoveContentIdFromAddress(account1, "dns%3Afoo.com");
```

#### adminRemoveAllContentIdsFromAddress()
Admin removes *all* contentIds from a given address, regardless of isWhitelisted status. Auto-removes account from isWhitelisted.
Is pausable.
@param `target`: Address to remove all content ids from
```javascript
r.adminRemoveAllContentIdsFromAddress(account1);
```

#### adminGetAddressByContentId()
Admin: Get any address mapped to a contentId, regardless of isWhitelisted status.
* @param `contentId`
* @returns `target` address
```javascript
r.adminGetAddressByContentId("dns%3Abar.com");
// --> should return registrant address
r.adminGetAddressByContentId("dns%3Afoo.com");
// --> should return 0 address since it was removed earlier
r.adminGetAddressByContentId("dns%3Abar.com", {from: account2});
// --> should error 'ONLY_CONTRACT_OWNER'
```

#### adminGetContentIdsByAddress()
Admin: Get the contentId mapped to any address, regardless of whitelist status.
* @param target
* @returns array of contentId strings
```javascript
r.adminGetContentIdsByAddress(account1);
```

#### adminGetRegistrantByIndex()
Admin: Return registrant address by index (integer), regardless of isWhitelisted status.
* @param `index` represents the slot in public `registrants` array.
* @returns address or error if index does not exist.
```javascript
r.adminGetRegistrantByIndex(0);
```


## External/public-facing Registry Functions:

#### isWhitelisted()
Check isWhitelisted status boolean for an address.
Returns boolean.
```javascript
r.isWhitelisted(account1, {from: account1 });
// --> false (we removed all contentIds from acct1 so its not whitelisted)
r.isWhitelisted(account2, {from: account1 });
// --> true
```

#### registantTimestamp()
Any address can check the `block.timestamp` of when a registrant was registered, regardless of `isWhitelisted` status.
```javascript
r.registrantTimestamp(account1, {from: account2});
```

#### getRegistrantToReferrer()
Any address can get the address that referred a registrant, regardless of `isWhitelisted` status of either.
```javascript
r.getRegistrantToReferrer(account1);
r.getRegistrantToReferrer(account2);
```

#### getReferrerToRegistrants()
Any address can get the addresses that were referred by a registrant, regardless of `isWhitelisted` status of either.
```javascript
r.referrerToRegistrants(account1);
r.referrerToRegistrants(account2);
```

#### hasRegistered()
Any address can check if any address has ever registered, regardless of isWhitelisted status of either.
Returns boolean.
```javascript
r.hasRegistered(account1);
```

#### getRegistrantCount()
Get number of addresses that have ever registered, regardless of isWhitelisted status.
* @returns # of registrants as a Big Number
```javascript
r.getRegistrantCount({ from: account2 });
r.getRegistrantCount({ from: account1 });
// --> both should return Big Number, regardless of `from` whitelisted status
```

#### getRegistrantByIndex()
Any address can get a valid whitelisted account address by registrant index number.
* @param `index` number
* @returns address
```javascript
r.getRegistrantByIndex(1);
// --> returns account address
r.getRegistrantByIndex(0);
// --> should error "INVALID_ADDRESS" since this acct is not whitelisted now
```

#### getContentIdsByAddress()
Any address can get the contentIds mapped to a valid whitelisted address.
* @param `target` address
* @returns array of contentId strings
```javascript
r.getContentIdsByAddress(account3, {from: account2});
// --> returns account3's contentIds
r.getContentIdsByAddress(account1, {from: account2});
// --> should error since account1 is no longer whitelisted
```

#### getAddressByContentId()
Any account can get valid whitelist address mapped to a contentId.
* @param `contentId`
* @returns address
```javascript
r.getAddressByContentId("dns%3Abaz.com", {from: account1});
// --> should return registrant address
r.getAddressByContentId("dns%3Afoo.com", {from: account2});
// --> should error "INVALID_ADDRESS" since acct is not whitelisted
```

#### removeContentIdFromAddress()
Valid whitelisted address can remove its own content id. Auto-removes address from `isWhitelisted`.
Is pausable.
* @param `contentId`: Content id to remove.
```javascript
r.removeContentIdFromAddress("dns%3Afoo.com");
```

#### removeAllContentIdsFromAddress()
Valid whitelisted address can remove *all* contentIds from itself. Auto-removes address from isWhitelisted.
Is pausable.
@param `target`: Address to remove all content ids from
```javascript
r.removeAllContentIdsFromAddress(account2);
```

#### isContentIdRegisteredToCaller()
Valid whitelisted address confirms registration of its own single content id.
Uses `tx.origin` (vs `msg.sender`) because this function will be called by the Microsponsors ERC-721 contract during the token minting process to confirm that the calling address has the right to mint tokens against a contentId.
* @param `federationId`:
* @param `contentId`: UTF8 encoded Microsponsors SRN (see utils.js lib).
* @returns boolean
```javascript
r.isContentIdRegisteredToCaller(1, "dns%3Azap.com", {from: account3 });
// --> true
r.isContentIdRegisteredToCaller(1, "dns%3Azap.com", {from: account2 });
// --> should error "INVALID_SENDER" since account2 doesn't have this contentId
r.isContentIdRegisteredToCaller(1, "dns%3Afoo.com", {from: account1 });
// --> should error "INVALID SENDER" since account1 is not whitelisted anymore

```

#### isMinter()
Public permissions check.
Will be called by Microsponsors ERC-721 contract.
```javascript
r.isMinter(1, account1);
r.isMinter(1, account3);
```

#### isAuthorizedTransferFrom()
Public permissions check.
Will be called by Microsponsors ERC-721 contract.

---

## Contract Admin

### Contract Owners
There are two contract owners which have equivalent Admin roles in this contract. Both are set during contract creation to the `msg.sender` and can be updated at any time (regardless of whether contract is paused or not).

#### owner1()
Public function that returns contract owner1 ("Admin" role #1).
```
r.owner1()
```
#### owner2()
Public function that returns contract owner2 ("Admin" role #2).
```
r.owner2()
```

### Transfer Ownership

#### transferOwnership1()
* @param `newOwner`: Address to transfer Owner/Admin role of contract to
```javascript
 r.transferOwnership1(account1)
```

#### transferOwnership2()
* @param `newOwner`: Address to transfer Owner/Admin role of contract to
```javascript
 r.transferOwnership2(account2)
```

### Pause Contract

#### paused()
Public function for querying status registry contract is paused or not.
* @returns boolean

#### pause()
Owner/Admin only: Pauses updating of contract state (updating whitelist statuses, content registrations, referrals, etc). Does not stop reads or content id validation in `isContentIdRegisteredToCaller()` used by our ERC-721s.

#### unpause()
Owner/Admin only: Unpause updating of registry contract state.

---

## Other Scenarios

#### reject `sendTransaction()`
We are rejecting all ETH from being sent here, to prevent accidents.
```javascript
web3.eth.sendTransaction({ from: admin, to: contractAddr, value: '1' });
//  --> should throw error!
web3.eth.getBalance(contractAddr);
//  --> should still be 0
```
