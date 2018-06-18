pragma solidity ^0.4.24;

contract Middleman {
    function receiveOrder() public {}
}

contract BulkBuyer {
    function receiveStartOfProduction() public {}
    function receiveProduct() public {}
}

contract MiddlemanFactory {
    function createInstance() public returns(address) {}
}

contract SpecialCarrierFactory {
    function getAccessAddress() public returns(address) {}
}

contract BulkBuyerFactory {
    function getAccessAddress() public returns(address) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract Manufacturer {
    event OrderReceived();
    event PartsReceived();
    event Selfdestructed();

    Middleman _middleman;
    BulkBuyer _bulkBuyer;
    Access _specialCarrierAccess;
    Access _bulkBuyerAccess;
    address _factory;

    modifier bulkBuyerAuthorized(string taskName) {
        _bulkBuyerAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    modifier specialCarrierAuthorized(string taskName) {
        _specialCarrierAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address middlemanInstance, address specialCarrierAccess, address bulkBuyerAccess) public {
        _factory = msg.sender;
        _middleman = Middleman(middlemanInstance);
        _specialCarrierAccess = Access(specialCarrierAccess);
        _bulkBuyerAccess = Access(bulkBuyerAccess);
    }

    function setBulkBuyer(address bulkBuyer) public bulkBuyerAuthorized("setBulkBuyer") {
        _bulkBuyer = BulkBuyer(bulkBuyer);
    }

    function receiveOrder() public bulkBuyerAuthorized("receiveOrder") {
        emit OrderReceived();
    }

    function placeOrder() public {
        _middleman.receiveOrder();
    }

    function receiveParts() public specialCarrierAuthorized("receiveParts") {
        emit PartsReceived();
    }

    function reportStartOfProduction() public {
        _bulkBuyer.receiveStartOfProduction();
    }

    function deliverProduct() public {
        _bulkBuyer.receiveProduct();
        selfdestruct(_factory);
    }
}

contract ManufacturerFactory {
    event ManufacturerInstanceCreated(address instanceAddress);

    address _accessAddress;
    MiddlemanFactory _middlemanFactory;
    SpecialCarrierFactory _specialCarrierFactory;
    BulkBuyerFactory _bulkBuyerFactory;

    constructor(address accessAddress, address middlemanAddress, address specialCarrierAddress, address bulkBuyerAddress) public {
        _accessAddress = accessAddress;
        _middlemanFactory = MiddlemanFactory(middlemanAddress);
        _specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
        _bulkBuyerFactory = BulkBuyerFactory(bulkBuyerAddress);
    }

    function createInstance() public returns(address) {
        address middlemanInstance = _middlemanFactory.createInstance();
        address specialCarrierAccess = _specialCarrierFactory.getAccessAddress();
        address bulkBuyerAccess = _bulkBuyerFactory.getAccessAddress();
        Manufacturer m = new Manufacturer(middlemanInstance, specialCarrierAccess, bulkBuyerAccess);
        emit ManufacturerInstanceCreated(m);
        return m;
    }
}
