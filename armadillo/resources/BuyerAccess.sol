pragma solidity ^0.4.24;

contract BuyerAccess {
    
    function isAuthorized(address buyerAddress) public returns(bool isAuthorized) {
        return buyerAddress == 0xf17f52151ebef6c7334fad080c5704d77216b732;
    }
}