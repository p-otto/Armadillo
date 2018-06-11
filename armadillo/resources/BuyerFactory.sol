pragma solidity ^0.4.24;

contract Seller {
    function receiveBuyOrder() public {}
}

contract SellerFactory {
    function createInstance() public returns(address sellerInstanceAddress) {}
}

contract Buyer {
    event ProductReceived();
    event Selfdestructed();

    Seller _sellerContract;
    address _factory;

    constructor(address seller_instance_address) public {
        _factory = msg.sender;
        _sellerContract = Seller(seller_instance_address);
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

    function createInstance() public returns(address buyerInstanceAddress) {
        address sellerInstanceAddress = _sellerFactory.createInstance();
        Buyer b = new Buyer(sellerInstanceAddress);
        emit BuyerInstanceCreated(b);
        return b;
    }

    function setSellerFactoryContract(address factory_address) public {
        _sellerFactory = SellerFactory(factory_address);
    }
}
