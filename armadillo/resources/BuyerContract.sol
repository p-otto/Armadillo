pragma solidity ^0.4.24;

contract SellerContract {
    function receiveBuyOrder() public {}
}

contract BuyerContract {
    event ProductReceived();

    SellerContract _sellerContract;

    constructor() public {}

    function setSellerContract(address contract_address) public {
        _sellerContract = SellerContract(contract_address);
    }

    function sendBuyOrder() public {
        _sellerContract.receiveBuyOrder();
    }

    function receiveProduct() public {
        emit ProductReceived();
    }
}
