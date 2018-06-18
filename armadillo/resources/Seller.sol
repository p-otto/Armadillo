pragma solidity ^0.4.24;

contract Buyer {
    function receiveProduct() public {}
}

contract BuyerAccess {
    function isAuthorized(address, string) public returns(bool) {}
}

contract Seller {
    event BuyOrderReceived();
    event Selfdestructed();

    Buyer _buyerContract;
    address _factory;
    BuyerAccess _buyerAccess;

    modifier authorized(string taskName) {
        _buyerAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address remoteAccessAddress) public {
        _factory = msg.sender;
        _buyerAccess = BuyerAccess(remoteAccessAddress);
    }

    function receiveBuyOrder() public authorized("receiveBuyOrder") {
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

    function createInstance(address remoteAccessAddress) public returns(address sellerInstanceAddress) {
        Seller s = new Seller(remoteAccessAddress);
        emit SellerInstanceCreated(s);
        return s;
    }
}
