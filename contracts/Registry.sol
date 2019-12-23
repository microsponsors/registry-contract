/*

  Copyright 2019 Niche Networks, Inc. (owns & operates Microsponsors.io)

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.5;
pragma experimental ABIEncoderV2;

import "@0x/contracts-utils/contracts/src/Ownable.sol";


contract Registry is
    Ownable
{


    /***  Microsponsors Registry Data:  ***/


    // Array of registrant addresses,
    // regardless of isWhitelisted status
    address[] private registrants;

    // Map address => whitelist status.
    // Addresses authorized to transact.
    mapping (address => bool) public isWhitelisted;

    // Map address => array of ContentId structs.
    // Using struct because there is not mapping to an array of strings in Solidity at this time.
    struct ContentIdStruct {
        string contentId;
    }
    mapping (address => ContentIdStruct[]) private addressToContentIds;

    // Map contentId => address (for reverse-lookups)
    mapping (string => address) private contentIdToAddress;

    // Pause. When true, Registry state updates and 0x order fills are blocked.
    bool public paused = false;


    /***  Constructor  ***/

    constructor ()
        public
    {

    }


    /***  Admin functions (onlyOwner) that mutate contract state  ***/


    /// @dev Admin registers an address with a contentId.
    /// @param target Address to add or remove from whitelist.
    /// @param contentId To map the address to. Hex-encoded UTF8 string.
    /// @param isApproved Whitelist status to assign to the address.
    function adminUpdate(
        address target,
        string calldata contentId,
        bool isApproved
    )
        external
        onlyOwner
        whenNotPaused
    {

        address previousOwner = contentIdToAddress[contentId];

        if (previousOwner != target) {

            // If contentId already belongs to another owner address
            // it must be explicitly removed by admin remove fn
            // which will also remove that address from whitelist
            // if this was its only contentId
            if (previousOwner != 0x0000000000000000000000000000000000000000) {
                adminRemoveContentIdFromAddress(previousOwner, contentId);
            }

            // Assign content id to new registrant address
            addressToContentIds[target].push( ContentIdStruct(contentId) );
            contentIdToAddress[contentId] = target;

        }

        if (!hasRegistered(target)) {
            registrants.push(target);
        }

        isWhitelisted[target] = isApproved;

    }


    /// @dev Admin updates whitelist status for a given address.
    /// @param target Address to update.
    /// @param isApproved Whitelist status to assign to address.
    function adminUpdateWhitelistStatus(
        address target,
        bool isApproved
    )
        external
        onlyOwner
        whenNotPaused
    {

        // Revert transaction (refund gas) if
        // the requested whitelist status update is redundant
        require(
            isApproved != isWhitelisted[target],
            'NO_STATUS_UPDATE_REQUIRED'
        );

        // Disallow users with no associated content ids
        // (ex: admin or user themselves may have removed content ids)
        if (isApproved == true) {
            require(
                getNumContentIds(target) > 0,
                'ADDRESS_HAS_NO_ASSOCIATED_CONTENT_IDS'
            );
        }

        isWhitelisted[target] = isApproved;

    }

    /// @dev Admin removes a contentId from a given address.
    function adminRemoveContentIdFromAddress(
        address target,
        string memory contentId
    )
        public
        onlyOwner
        whenNotPaused
    {

        require(
            contentIdToAddress[contentId] == target,
            'CONTENT_ID_DOES_NOT_BELONG_TO_ADDRESS'
        );

        contentIdToAddress[contentId] = address(0x0000000000000000000000000000000000000000);

        // Remove content id from addressToContentIds mapping
        // by replacing it with empty string
        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            if (stringsMatch(contentId, m[i].contentId)) {
                addressToContentIds[target][i] = ContentIdStruct('');
            }
        }

        // If address has no valid content ids left, remove from Whitelist
        if (getNumContentIds(target) == 0) {
            isWhitelisted[target] = false;
        }

    }

    /// @dev Admin removes *all* contentIds from a given address.
    function adminRemoveAllContentIdsFromAddress(
        address target
    )
        public
        onlyOwner
        whenNotPaused
    {

        // Loop thru content ids from addressToContentIds mapping
        // by replacing each with empty string
        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            addressToContentIds[target][i] = ContentIdStruct('');
        }

        // Remove from whitelist
        isWhitelisted[target] = false;

    }


    /*** Admin read-only functions ***/


    /// @dev Returns count of all addresses that have *ever* registered,
    /// regardless of isWhitelisted status
    function adminGetRegistrantCount ()
        external
        view
        onlyOwner
        returns (uint)
    {

        return registrants.length;

    }

    function adminGetRegistrantByIndex (
        uint index
    )
        external
        view
        onlyOwner
        returns (address)
    {

        // Will throw error if specified index does not exist
        return registrants[index];

    }


    function adminGetAddressByContentId(
        string calldata contentId
    )
        external
        view
        onlyOwner
        returns (address target)
    {

        return contentIdToAddress[contentId];

    }


    /// @dev Admin gets contentIds mapped to a valid whitelisted address.
    /// @param target Ethereum address to validate & return contentIds for.
    function adminGetContentIdsByAddress(
        address target
    )
        external
        view
        onlyOwner
        returns (string[] memory)
    {

        ContentIdStruct[] memory m = addressToContentIds[target];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].contentId;
        }

        return r;

    }


    /*** User-facing functions ***/


    /// @dev Valid whitelisted address can query its own contentIds.
    ///      In practice, this is called from the Microsponsors dapp so a
    ///      user can view their own content ids.
    function getContentIdsByAddress()
        external
        view
        returns (string[] memory)
    {

        require(
            isWhitelisted[msg.sender],
            'INVALID_SENDER'
        );

        ContentIdStruct[] memory m = addressToContentIds[msg.sender];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].contentId;
        }

        return r;

    }

    /// @dev Valid whitelisted address validates registration of its own
    ///      single contentId.
    ///      In practice, this will be used by Microsponsors' ERC-721 for
    ///      validating that an address is authorized to mint() a time slot
    ///      for a given content id.
    function isContentIdRegisteredToCaller(string calldata contentId)
        external
        view
        returns(bool)
    {

        // Check tx.origin vs msg.sender since this will be invoked by
        // Microsponsors' ERC-721 contract
        require(
            isWhitelisted[tx.origin],
            'INVALID_SENDER'
        );

        address registrantAddress = contentIdToAddress[contentId];

        require(
            registrantAddress == tx.origin,
            'INVALID_SENDER'
        );

        return true;

    }


    /// @dev Valid whitelisted address can remove its own content id.
    function removeContentIdFromAddress(
        string calldata contentId
    )
        external
        whenNotPaused
    {

        require(
            isWhitelisted[msg.sender],
            'INVALID_SENDER'
        );

        require(
            contentIdToAddress[contentId] == msg.sender,
            'CONTENT_ID_DOES_NOT_BELONG_TO_SENDER'
        );

        contentIdToAddress[contentId] = address(0x0000000000000000000000000000000000000000);

        // Remove content id from addressToContentIds mapping
        // by replacing it with empty string
        ContentIdStruct[] memory m = addressToContentIds[msg.sender];
        for (uint i = 0; i < m.length; i++) {
            if (stringsMatch(contentId, m[i].contentId)) {
                addressToContentIds[msg.sender][i] = ContentIdStruct('');
            }
        }

        // If address has no valid content ids left, remove from Whitelist
        if (getNumContentIds(msg.sender) == 0) {
            isWhitelisted[msg.sender] = false;
        }

    }


    /// @dev Valid whitelisted address can remove *all* contentIds from itself.
    function removeAllContentIdsFromAddress(
        address target
    )
        external
        whenNotPaused
    {

        require(
            isWhitelisted[msg.sender],
            'INVALID_SENDER'
        );

        require(
            target == msg.sender,
            'INVALID_SENDER'
        );

        // Loop thru content ids from addressToContentIds mapping
        // by replacing each with empty string
        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            addressToContentIds[target][i] = ContentIdStruct('');
        }

        // Remove from whitelist
        isWhitelisted[target] = false;

    }



    /*** Pausable: Adapted from OpenZeppelin (via Cryptokitties) ***/


    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by contract owner to pause actions on this contract
    function pause() external onlyOwner whenNotPaused {
        paused = true;
    }

    /// @dev Called by contract owner to unpause the smart contract.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyOwner whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }


    /***  Helpers  ***/


    /// @dev Check if an address has *ever* registered,
    /// regardless of isWhitelisted status
    function hasRegistered (
        address target
    )
        public
        view
        returns(bool)
    {

        bool _hasRegistered = false;
        for (uint i=0; i<registrants.length; i++) {
            if (registrants[i] == target) {
                return _hasRegistered = true;
            }
        }

    }


    function stringsMatch (
        string memory a,
        string memory b
    )
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }


    function getNumContentIds (
        address target
    )
        private
        view
        returns (uint16)
    {

        ContentIdStruct[] memory m = addressToContentIds[target];
        uint16 counter = 0;
        for (uint i = 0; i < m.length; i++) {
            // Omit entries that are empty strings
            // (from contentIds that were removed by admin or user)
            if (!stringsMatch('', m[i].contentId)) {
                counter++;
            }
        }

        return counter;

    }


}
