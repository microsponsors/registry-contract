// Adaped from "@0x/contracts-utils/contracts/src/Ownable.sol";

pragma solidity ^0.5.5;

import "./IOwnable.sol";


contract Ownable is
    IOwnable
{
    address public owner1;
    address public owner2;

    constructor ()
        public
    {
        owner1 = msg.sender;
        owner2 = msg.sender;
    }

    modifier onlyOwner() {
        require(
            (msg.sender == owner1) || (msg.sender == owner2),
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership1(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner1 = newOwner;
        }
    }

    function transferOwnership2(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner2 = newOwner;
        }
    }

}
