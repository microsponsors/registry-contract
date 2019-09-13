# Test Cases and Scenarios

## Registration Admin

#### adminUpdate(
"0xcf63f2a7321bffca76f9cfa4ab3b5aaa4a034c93", "dns:foo.com", true
)
#### adminUpdateWhitelistStatus()
#### adminGetRegistrantByIndex()
#### pause()
#### unpause()

## Content Id Registration Admin

#### adminRemoveContentIdFromAddress()
#### adminGetRegistrantCount()
#### adminGetAddressByContentId()
#### adminGetContentIdsByAddress()

## Content Id Registration - User-facing

#### isWhitelisted()
#### hasRegistered()
#### getContentIdsByAddress()
#### removeContentIdFromAddress()

## Integration with ERC-721 + 0x Protocol Exchange Fns

#### isContentIdRegisteredToCaller()
#### isValidSignature()
#### fillOrderIfWhitelisted()
