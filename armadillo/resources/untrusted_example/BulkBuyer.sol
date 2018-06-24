pragma solidity ^0.4.24;

contract Manufacturer {
    function receiveOrder(address) public;
    function setBulkBuyer(address) public;
}

contract ManufacturerFactory {
    function createInstance(uint) public returns(address);
    function getAccessAddress() public returns(address);
    function isInstance(uint, address) public view returns(bool);
}

contract Access {
    function isAuthorized(address, string) public returns(bool);
}

contract BulkBuyer {
    event ProductReceived();
    event StartOfProductionReceived();
    event Selfdestructed();

    address _factory;
    Access _localAccess;
    uint _id;

    ManufacturerFactory _manufacturerFactory;
    Access _manufacturerAccess;
    Manufacturer _manufacturer;

    modifier manufacturerAuthorized(address sender, string taskName) {
        require(_manufacturerFactory.isInstance(_id, msg.sender));
        require(_manufacturerAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    constructor(
        address localAccess,
        uint counter,
        address manufacturerFactory, address manufacturerAccess, address manufacturerInstance
    ) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;

        _manufacturerFactory = ManufacturerFactory(manufacturerFactory);
        _manufacturerAccess = Access(manufacturerAccess);
        _manufacturer = Manufacturer(manufacturerInstance);
    }

    function sendOrder() public localAuthorized("receiveOrder") {
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

    Access _access;
    uint _counter;

    address _manufacturerAddress = address(0);

    mapping(uint => address) _instances;

    modifier initialized {
        require(_manufacturerAddress != address(0));
        _;
    }

    constructor(address accessAddress) public {
        _access = Access(accessAddress);
        _counter = 0;
    }

    function setManufacturer(address manufacturerAddress) public {
        _manufacturerAddress = manufacturerAddress;
    }

    function createInstance() public initialized returns(address) {
        _counter = _counter + 1;

        ManufacturerFactory manufacturerFactory = ManufacturerFactory(_manufacturerAddress);
        address manufacturerAccess = manufacturerFactory.getAccessAddress();
        address manufacturerInstance = manufacturerFactory.createInstance(_counter);

        BulkBuyer b = new BulkBuyer(
            _access,
            _counter,
            manufacturerFactory, manufacturerAccess, manufacturerInstance
        );
        _instances[_counter] = address(b);
        emit BulkBuyerInstanceCreated(b);
        return b;        
    }

    function isInstance(uint id, address instanceAddress) public view returns(bool) {
        return _instances[id] == instanceAddress;
    }
}
