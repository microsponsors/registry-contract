# Test Cases and Scenarios

## Contract Admin:
#### pause()
#### unpause()
#### transferOwnership()

## Registry Admin:
#### adminUpdate()
#### adminUpdateWithReferrer()
#### adminUpdateRegistrantToReferrer()
#### adminUpdateWhitelistStatus()
#### adminGetRegistrantByIndex()

## Content Id Registration Admin:
#### adminRemoveContentIdFromAddress()
#### adminGetRegistrantCount()
#### adminGetAddressByContentId()
#### adminGetContentIdsByAddress()
#### adminRemoveAllContentIdsFromAddress()

## Content Id Registration: Public or User-facing
#### isWhitelisted()
#### hasRegistered()
#### registantTimestamp()
#### registrantToReferrer()
#### getContentIdsByAddress()
#### removeContentIdFromAddress()
#### removeAllContentIdsFromAddress()

## Integration with ERC-721 and/or 0x Exchange fns:
#### isContentIdRegisteredToCaller()
