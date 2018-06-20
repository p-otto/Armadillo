pragma solidity ^0.4.24;

contract Manufacturer {
    function receiveOrder(address) public {}
    function setBulkBuyer(address) public {}
}

contract ManufacturerFactory {
    function createInstance(uint) public returns(address) {}
    function getAccessAddress() public returns(address) {}
    function isInstance(uint, address) public view returns(bool) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract BulkBuyer {
    event ProductReceived();
    event StartOfProductionReceived();
    event Selfdestructed();

    uint _id;
    Manufacturer _manufacturer;
    ManufacturerFactory _manufacturerFactory;
    Access _manufacturerAccess;
    Access _localAccess;
    address _factory;

    modifier manufacturerAuthorized(address sender, string taskName) {
        require(_manufacturerFactory.isInstance(_id, msg.sender));
        require(_manufacturerAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    constructor(address localAccess, uint counter, address manufacturerFactory, address manufacturerInstance, address manufacturerAccess) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;
        _manufacturer = Manufacturer(manufacturerInstance);
        _manufacturerFactory = ManufacturerFactory(manufacturerFactory);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function sendOrder() public localAuthorized("sendOrder") {
        _manufacturer.receiveOrder(msg.sender);
    }

    function receiveStartOfProduction(address sender) public manufacturerAuthorized(sender, "receiveStartOfProduction") {
        emit StartOfProductionReceived();
    }

    function receiveProduct(address sender) public manufacturerAuthorized(sender, "receiveProduct") {
        emit ProductReceived();
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract BulkBuyerFactory {
    event BulkBuyerInstanceCreated(address instanceAddress);

    address _accessAddress;
    uint _counter;

    mapping(uint => address) instances;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
        _counter = 0;
    }

    function createInstance(address manufacturerAddress) public returns(address) {
        _counter = _counter + 1;

        ManufacturerFactory manufacturerFactory = ManufacturerFactory(manufacturerAddress);
        address manufacturerInstance = manufacturerFactory.createInstance(_counter);
        Manufacturer manufacturer = Manufacturer(manufacturerInstance);

        address manufacturerAccess = manufacturerFactory.getAccessAddress();

        BulkBuyer b = new BulkBuyer(_accessAddress, _counter, manufacturerFactory, manufacturerInstance, manufacturerAccess);
        manufacturer.setBulkBuyer(b);
        emit BulkBuyerInstanceCreated(b);
        instances[_counter] = address(b);
        return b;
    }

    function isInstance(uint id, address instanceAddress) public view returns(bool) {
        return instances[id] == instanceAddress;
    }
}
