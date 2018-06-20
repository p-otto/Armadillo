pragma solidity ^0.4.24;

contract Manufacturer {
    function receiveOrder() public {}
    function setBulkBuyer(address) public {}
}

contract ManufacturerFactory {
    function createInstance() public returns(address) {}
    function getAccessAddress() public returns(address) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract BulkBuyer {
    event ProductReceived();
    event StartOfProductionReceived();
    event Selfdestructed();

    Manufacturer _manufacturer;
    Access _manufacturerAccess;
    address _factory;

    modifier authorized(string taskName) {
        _manufacturerAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address manufacturerInstance, address manufacturerAccess) public {
        _factory = msg.sender;
        _manufacturer = Manufacturer(manufacturerInstance);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function sendOrder() public {
        _manufacturer.receiveOrder();
    }

    function receiveStartOfProduction() public authorized("receiveStartOfProduction") {
        emit StartOfProductionReceived();
    }

    function receiveProduct() public authorized("receiveProduct") {
        emit ProductReceived();
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract BulkBuyerFactory {
    event BulkBuyerInstanceCreated(address instanceAddress);

    address _accessAddress;
    ManufacturerFactory _manufacturerFactory;

    constructor(address accessAddress, address manufacturerAddress) public {
        _accessAddress = accessAddress;
        _manufacturerFactory = ManufacturerFactory(manufacturerAddress);
    }

    function createInstance() public returns(address) {
        address manufacturerInstance = _manufacturerFactory.createInstance();
        Manufacturer manufacturer = Manufacturer(manufacturerInstance);
        address accessAddress = _manufacturerFactory.getAccessAddress();
        BulkBuyer b = new BulkBuyer(manufacturerInstance, accessAddress);
        manufacturer.setBulkBuyer(b);
        emit BulkBuyerInstanceCreated(b);
        return b;
    }
}
