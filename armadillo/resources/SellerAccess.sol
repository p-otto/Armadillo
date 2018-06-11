pragma solidity ^0.4.24;

contract SellerAccess {
    
    function isAuthorized(address buyerAddress) public returns(bool isAuthorized) {
        return buyerAddress == 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;
    }
}