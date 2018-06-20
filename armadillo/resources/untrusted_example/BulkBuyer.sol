pragma solidity ^0.4.24;

contract Manufacturer {
    function receiveOrder(address) public {}
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

    modifier authorized(string taskName, address sender) {
        require(msg.sender == address(_manufacturer));
        require(_manufacturerAccess.isAuthorized(sender, taskName));
        _;
    }

    constructor(address manufacturerInstance, address manufacturerAccess) public {
        _factory = msg.sender;
        _manufacturer = Manufacturer(manufacturerInstance);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function sendOrder() public {
        _manufacturer.receiveOrder(msg.sender);
    }

    function receiveStartOfProduction(address sender) public authorized("receiveStartOfProduction", sender) {
        emit StartOfProductionReceived();
    }

    function receiveProduct(address sender) public authorized("receiveProduct", sender) {
        emit ProductReceived();
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract BulkBuyerFactory {
    event BulkBuyerInstanceCreated(address instanceAddress);

    address _accessAddress;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(address manufacturerAddress) public returns(address) {
        ManufacturerFactory manufacturerFactory = ManufacturerFactory(manufacturerAddress);
        address manufacturerInstance = manufacturerFactory.createInstance();
        Manufacturer manufacturer = Manufacturer(manufacturerInstance);
        address accessAddress = manufacturerFactory.getAccessAddress();
        BulkBuyer b = new BulkBuyer(manufacturerInstance, accessAddress);
        manufacturer.setBulkBuyer(b);
        emit BulkBuyerInstanceCreated(b);
        return b;
    }
}
