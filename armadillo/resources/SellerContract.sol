pragma solidity ^0.4.24;

contract BuyerContract {
    function receiveProduct() public {}
}

contract SellerContract {
    event BuyOrderReceived();

    BuyerContract _buyerContract;

    constructor() public {}

    function receiveBuyOrder() public {
        _buyerContract = BuyerContract(msg.sender);
        emit BuyOrderReceived();
    }

    function sendProduct() public {
        _buyerContract.receiveProduct();
    }
}
