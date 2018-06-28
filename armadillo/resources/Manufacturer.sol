pragma solidity ^0.4.24;

contract Middleman {
    function receiveOrder(address) public;
    function setManufacturer(address) public;
}

contract BulkBuyer {
    function receiveStartOfProduction(address) public;
    function receiveProduct(address) public;
}

contract MiddlemanFactory {
    function createInstance(uint) public returns(address);
}

contract SpecialCarrierFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);

}

contract BulkBuyerFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract Access {
    function isAuthorized(address, string) public returns(bool);
}

contract Manufacturer {
    event OrderReceived();
    event PartsReceived();
    event Selfdestructed();

    address _factory;
    Access _localAccess;
    uint _id;

    Middleman _middleman;
    SpecialCarrierFactory _specialCarrierFactory;
    Access _specialCarrierAccess;
    BulkBuyerFactory _bulkBuyerFactory;
    Access _bulkBuyerAccess;
    BulkBuyer _bulkBuyer;

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    modifier bulkBuyerAuthorized(address sender, string taskName) {
        require(_bulkBuyerFactory.isInstance(_id, msg.sender));
        require(_bulkBuyerAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier specialCarrierAuthorized(address sender, string taskName) {
        require(_specialCarrierFactory.isInstance(_id, msg.sender));
        require(_specialCarrierAccess.isAuthorized(sender, taskName));
        _;
    }

    constructor(
        address localAccess,
        uint counter,
        address middlemanInstance,
        address specialCarrierFactory, address specialCarrierAccess,
        address bulkBuyerFactory, address bulkBuyerAccess
    ) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;

        _middleman = Middleman(middlemanInstance);
        _specialCarrierFactory = SpecialCarrierFactory(specialCarrierFactory);
        _specialCarrierAccess = Access(specialCarrierAccess);
        _bulkBuyerFactory = BulkBuyerFactory(bulkBuyerFactory);
        _bulkBuyerAccess = Access(bulkBuyerAccess);
    }

    function receiveOrder(address sender) public bulkBuyerAuthorized(sender, "receiveOrder") {
        _bulkBuyer = BulkBuyer(msg.sender);
        emit OrderReceived();
    }

    function placeOrder() public localAuthorized("receiveOrder") {
        _middleman.receiveOrder(msg.sender);
    }

    function receiveParts(address sender) public specialCarrierAuthorized(sender, "receiveParts") {
        emit PartsReceived();
    }

    function reportStartOfProduction() public localAuthorized("receiveStartOfProduction") {
        _bulkBuyer.receiveStartOfProduction(msg.sender);
    }

    function deliverProduct() public localAuthorized("receiveProduct") {
        _bulkBuyer.receiveProduct(msg.sender);
        emit Selfdestructed();
        selfdestruct(_factory);
    }
}

contract ManufacturerFactory {
    event ManufacturerInstanceCreated(address instanceAddress);

    address _accessAddress;
    mapping(uint => address) _instances;

    address _middlemanAddress = address(0);
    address _bulkBuyerAddress = address(0);
    address _specialCarrierAddress = address(0);


    modifier initialized {
        require(_middlemanAddress != address(0));
        require(_bulkBuyerAddress != address(0));
        require(_specialCarrierAddress != address(0));
        _;
    }

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function setMiddleman(address middlemanAddress) public {
        _middlemanAddress = middlemanAddress;
    }

    function setBulkBuyer(address bulkBuyerAddress) public {
        _bulkBuyerAddress = bulkBuyerAddress;
    }
    
    function setSpecialCarrier(address specialCarrierAddress) public {
        _specialCarrierAddress = specialCarrierAddress;
    }

    function createInstance(uint counter) public initialized returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(_middlemanAddress);
        address middlemanInstance = middlemanFactory.createInstance(counter);

        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(_specialCarrierAddress);
        address specialCarrierAccess = specialCarrierFactory.getAccessAddress();

        BulkBuyerFactory bulkBuyerFactory = BulkBuyerFactory(_bulkBuyerAddress);
        address bulkBuyerAccess = bulkBuyerFactory.getAccessAddress();

        Manufacturer m = new Manufacturer(
            _accessAddress,
            counter,
            middlemanInstance,
            specialCarrierFactory, specialCarrierAccess,
            bulkBuyerFactory, bulkBuyerAccess);

        _instances[counter] = address(m);
        emit ManufacturerInstanceCreated(m);
        return m;
    }

    function isInstance(uint id, address instanceAddress) public view returns(bool) {
        return _instances[id] == instanceAddress;
    }

    function getAccessAddress() public view returns(address) {
        return _accessAddress;
    }
}
