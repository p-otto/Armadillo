pragma solidity ^0.4.24;

contract Middleman {
    function receiveOrder(address) public {}
    function setManufacturer(address) public {}
}

contract BulkBuyer {
    function receiveStartOfProduction(address) public {}
    function receiveProduct(address) public {}
}

contract SpecialCarrier {}

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

    uint _id;
    Middleman _middleman;
    BulkBuyer _bulkBuyer;
    SpecialCarrier _specialCarrier;
    BulkBuyerFactory _bulkBuyerFactory;
    SpecialCarrierFactory _specialCarrierFactory;
    Access _specialCarrierAccess;
    Access _bulkBuyerAccess;
    Access _localAccess;
    address _factory;

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

    constructor(address localAccess, uint counter, address middlemanInstance, address specialCarrierAccess, address bulkBuyerAccess) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;
        _middleman = Middleman(middlemanInstance);
        _specialCarrierAccess = Access(specialCarrierAccess);
        _bulkBuyerAccess = Access(bulkBuyerAccess);
    }

    function receiveOrder(address sender) public bulkBuyerAuthorized(sender, "receiveOrder") {
        emit OrderReceived();
    }

    function placeOrder() public {
        _middleman.receiveOrder(msg.sender);
    }

    function receiveParts(address sender) public specialCarrierAuthorized(sender, "receiveParts") {
        emit PartsReceived();
    }

    function reportStartOfProduction() public localAuthorized("reportStartOfProduction") {
        _bulkBuyer.receiveStartOfProduction(msg.sender);
    }

    function deliverProduct() public localAuthorized("deliverProduct") {
        _bulkBuyer.receiveProduct(msg.sender);
        selfdestruct(_factory);
    }
}

contract ManufacturerFactory {
    event ManufacturerInstanceCreated(address instanceAddress);

    address _accessAddress;
    mapping(uint => address) instances;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(uint counter, address middlemanAddress, address specialCarrierAddress, address bulkBuyerAddress) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(middlemanAddress);
        address middlemanInstance = middlemanFactory.createInstance();
        Middleman middleman = Middleman(middlemanInstance);

        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
        address specialCarrierAccess = specialCarrierFactory.getAccessAddress();

        BulkBuyerFactory bulkBuyerFactory = BulkBuyerFactory(bulkBuyerAddress);
        address bulkBuyerAccess = bulkBuyerFactory.getAccessAddress();
        Manufacturer m = new Manufacturer(_accessAddress, counter, middlemanInstance, specialCarrierAccess, bulkBuyerAccess);
        middleman.setManufacturer(m);
        instances[counter] = address(m);
        emit ManufacturerInstanceCreated(m);
        return m;
    }
}
