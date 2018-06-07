pragma solidity ^0.4.24;

contract Seller {
    function receiveBuyOrder() public {}
}

contract Buyer {
    event ProductReceived();

    Seller _sellerContract;
    address _factory;

    constructor() public {
        _factory = msg.sender;
    }

    function setSellerContract(address contract_address) public {
        _sellerContract = Seller(contract_address);
    }

    function sendBuyOrder() public {
        _sellerContract.receiveBuyOrder();
    }

    function receiveProduct() public {
        emit ProductReceived();
        selfdestruct(_factory);
    }
}

contract BuyerFactory {
    event BuyerInstanceCreated(address instanceAddress);

    function createInstance() public returns(address buyerInstanceAddress) {
        Buyer b = new Buyer();
        emit BuyerInstanceCreated(b);
        return b;
    }
}
