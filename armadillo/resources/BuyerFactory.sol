pragma solidity ^0.4.24;

contract Seller {
    function receiveBuyOrder() public {}
}

contract SellerFactory {
    function createInstance(address accessAddress) public returns(address sellerInstanceAddress) {}
}

contract SellerAccess {
    function isAuthorized(address buyerAddress) public returns(bool isAuthorized) {}
}

contract Buyer {
    event ProductReceived();
    event Selfdestructed();

    Seller _sellerContract;
    address _factory;
    SellerAccess _sellerAccess;

    constructor(address sellerInstanceAddress, address sellerAccess) public {
        _factory = msg.sender;
        _sellerContract = Seller(sellerInstanceAddress);
        _sellerAccess = SellerAccess(sellerAccess);
    }

    function sendBuyOrder() public {
        _sellerContract.receiveBuyOrder();
    }

    function receiveProduct() public {
        emit ProductReceived();
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract BuyerFactory {
    event BuyerInstanceCreated(address instanceAddress);

    SellerFactory _sellerFactory;

    function createInstance(address buyerAccess, address sellerAccess) public returns(address buyerInstanceAddress) {
        address sellerInstanceAddress = _sellerFactory.createInstance(buyerAccess);
        Buyer b = new Buyer(sellerInstanceAddress, sellerAccess);
        emit BuyerInstanceCreated(b);
        return b;
    }

    function setSellerFactoryContract(address factory_address) public {
        _sellerFactory = SellerFactory(factory_address);
    }
}
