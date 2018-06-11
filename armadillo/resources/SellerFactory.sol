pragma solidity ^0.4.24;

contract Buyer {
    function receiveProduct() public {}
}

contract Seller {
    event BuyOrderReceived();
    event Selfdestructed();

    Buyer _buyerContract;
    address _factory;

    constructor() public {
        _factory = msg.sender;
    }

    function receiveBuyOrder() public {
        _buyerContract = Buyer(msg.sender);
        emit BuyOrderReceived();
    }

    function sendProduct() public {
        _buyerContract.receiveProduct();
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract SellerFactory {
    event SellerInstanceCreated(address instanceAddress);

    function createInstance() public returns(address sellerInstanceAddress) {
        Seller s = new Seller();
        emit SellerInstanceCreated(s);
        return s;
    }
}
