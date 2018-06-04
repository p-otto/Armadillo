pragma solidity ^0.4.24;

contract BuyerContract {
	event ProductReceived();

	SellerContract _sellerContract;

	constructor() {}

	function setSellerContract(address contract_address) public {
		_sellerContract = SellerContract(contract_address);
	}

	function sendBuyOrder() {
		_sellerContract.receiveBuyOrder();
	}

	function receiveProduct() public {
		emit ProductReceived();
	}
}

contract SellerContract {
    event BuyOrderReceived();

    BuyerContract _buyerContract;

    constructor() {}

	function setBuyerContract(address contract_address) public {
		_buyerContract = BuyerContract(contract_address);
	}

    function receiveBuyOrder() public {
    	emit BuyOrderReceived();
    }

    function sendProduct() public {
    	_buyerContract.receiveProduct();
    }
}
