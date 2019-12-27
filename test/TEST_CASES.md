# Test Cases

## Contract Admin Functions:
#### pause()
#### unpause()
#### transferOwnership()

## Registry Admin Functions:
#### adminUpdate()
#### adminUpdateWithReferrer()
#### adminUpdateRegistrantToReferrer()
#### adminUpdateWhitelistStatus()
#### adminRemoveContentIdFromAddress()
#### adminRemoveAllContentIdsFromAddress()
#### adminGetAddressByContentId()
#### adminGetContentIdsByAddress()
#### adminGetRegistrantByIndex()

## External/public -facing Functions:
#### isWhitelisted()
#### hasRegistered()
#### getRegistrantCount()
#### getRegistrantByIndex()
#### registantTimestamp()
#### registrantToReferrer()
#### getAddressByContentId()
#### getContentIdsByAddress()
#### removeContentIdFromAddress()
#### removeAllContentIdsFromAddress()

## Integration with ERC-721 and/or 0x Exchange Functions:
#### isContentIdRegisteredToCaller()

---

# Test Scenarios

## Local Setup

Start ganache, then truffle console locally:
```
$ ganache-cli -p 8545
$ truffle console --network development
> Registry.deployed().then(inst => { r = inst })
```
The following test scenarios assume you're querying from truffle console.
`r` = registry instance created when you deployed the Registry (above).


## Registry Admin

#### adminUpdate()
Admin: Add/remove address to whitelist, map it to contentId.
Is pausable.
* @param `target`: Address to add or remove from whitelist.
* @param `contentId`: UTF8 encoded Microsponsors contentId (see utils.js)
* @param `isApproved`: isWhitelisted status boolean for address.
```
r.adminUpdate(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "dns%3Afoo.com",
  true)
```
The `contentId` is designed to be pretty flexible in this contract (just a simple string) to allow for maximum forward-compatibility. Details on format [here](https://github.com/microsponsors/utils.js#contentid).

#### adminUpdateWithReferrer()
Admin: Same params as `adminUpdate` with one additional, below:
Is pausable.
* @param `referrer`: the address referring the target, only if `isWhitelisted`
```
r.adminUpdateWithReferrer("0xa10d39dd0224f1c1b670a699cd85c1a794bcdf30", "dns%3Abaz.com", true, "0xc835cf67962948128157de5ca5b55a4e75f572d2");
```

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
r.adminUpdateWhitelistStatus(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  false
);
```

#### adminRemoveContentIdFromAddress()
Is pausable.
* @param `target`: Address to remove content id from.
* @param `contentId`: Content id to remove.
```
r.adminRemoveContentIdFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2",
  "dns%3Afoo.com"
);
```

#### adminRemoveAllContentIdsFromAddress()
Admin removes *all* contentIds from a given address, regardless of isWhitelisted status. Auto-removes account from isWhitelisted.
Is pausable.
@param `target`: Address to remove all content ids from
```
r.adminRemoveAllContentIdsFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2"
);
```

#### adminGetAddressByContentId()
Admin: Get any address mapped to a contentId, regardless of isWhitelisted status.
* @param `contentId`
* @returns `target` address
```
r.adminGetAddressByContentId("dns%3Afoo.com")
```

#### adminGetContentIdsByAddress()
Admin: Get the contentId mapped to any address, regardless of whitelist status.
* @param target
* @returns array of contentId strings
```
r.adminGetContentIdsByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### adminGetRegistrantByIndex()
Admin: Return registrant address by index (integer), regardless of isWhitelisted status.
* @param `index` represents the slot in public `registrants` array.
* @returns address or error if index does not exist.
```
> r.adminGetRegistrantByIndex(0)
```


## External/public -facing Functions:

#### isWhitelisted()
Check isWhitelisted status boolean for an address.
Returns boolean.
```
> r.isWhitelisted("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### registantTimestamp()
Any address can check the `block.timestamp` of when a registrant was registered, regardless of `isWhitelisted` status.
```
> r.registrantTimestamp("0xc835cf67962948128157de5ca5b55a4e75f572d2");
```

#### registrantToReferrer()
Any address can get the address that referred a registrant, regardless of `isWhitelisted` status of either.
```
> r.registrantToReferrer("0xa10d39dd0224f1c1b670a699cd85c1a794bcdf30");
```

#### hasRegistered()
Any address can check if any address has ever registered, regardless of isWhitelisted status of either.
Returns boolean.
```
> r.hasRegistered("0xc835cf67962948128157de5ca5b55a4e75f572d2")
```

#### getRegistrantCount()
Get number of addresses that have ever registered, regardless of isWhitelisted status.
* @returns # of registrants as a Big Number
```
> r.getRegistrantCount()
```

#### getRegistrantByIndex()
Any address can get a valid whitelisted account address by registrant index number.
* @param `index` number
* @returns `target` address
```
r.getRegistrantByIndex(0);
```

#### getContentIdsByAddress()
Any address can get the contentIds mapped to a valid whitelisted address.
* @param `target` address
* @returns array of contentId strings
```
r.getContentIdsByAddress("0xc835cf67962948128157de5ca5b55a4e75f572d2", {from: "0xa10d39dd0224f1c1b670a699cd85c1a794bcdf30"})
```

#### getAddressByContentId()
Admin: Get valid whitelist address mapped to a contentId.
* @param `contentId`
* @returns `target` address
```
r.adminGetAddressByContentId("dns%3Afoo.com")
```

#### removeContentIdFromAddress()
Valid whitelisted address can remove its own content id. Auto-removes address from isWhitelisted.
Is pausable.
* @param `contentId`: Content id to remove.
```
r.removeContentIdFromAddress("dns%3Afoo.com");
```

#### removeAllContentIdsFromAddress()
Valid whitelisted address can remove *all* contentIds from itself. Auto-removes address from isWhitelisted.
Is pausable.
@param `target`: Address to remove all content ids from
```
r.removeAllContentIdsFromAddress(
  "0xc835cf67962948128157de5ca5b55a4e75f572d2"
);
```

#### isContentIdRegisteredToCaller()
Valid whitelisted address confirms registration of its own single content id.
Uses `tx.origin` (vs `msg.sender`) because this function will be called by the Microsponsors ERC-721 contract during the token minting process to confirm that the calling address has the right to mint tokens against a contentId.
* @param `contentId`: UTF8 encoded Microsponsors SRN (see utils.js lib).
* @returns boolean
```
r.isContentIdRegisteredToCaller("dns%3Afoo.com")
```

---

## Contract Admin

### Contract Owner

#### owner()
Public function that returns contract owner (aka "Admin" here).
```
r.owner()
```

### Transfer Ownership

#### transferOwnership()
* @param `newOwner`: Address to transfer ownership of contract to

### Pause Contract

#### paused()
Public function for querying if this registry contract is paused or not.
* @returns boolean

#### pause()
Admin only: Pauses updating of contract state (updating whitelist statuses, content registrations, referrals, etc). Does not stop reads or content id validation in `isContentIdRegisteredToCaller()` used by our ERC-721s.

#### unpause()
Admin only: Unpause updating of registry contract state.




