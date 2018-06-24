pragma solidity ^0.4.24;

contract Supplier {
    function receiveRequest(address) public;
}

contract Manufacturer {
    function receiveParts(address) public;
}

contract MiddlemanFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract SupplierFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract Access {
    function isAuthorized(address, string) public returns(bool);
}

contract SpecialCarrier {
    event OrderReceived();
    event DetailsReceived();
    event WaybillReceived();
    event Selfdestructed();

    address _factory;
    Access _localAccess;
    uint _id;

    SupplierFactory _supplierFactory;
    Access _supplierAccess;
    Supplier _supplier;
    MiddlemanFactory _middlemanFactory;
    Access _middlemanAccess;
    Manufacturer _manufacturer;

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    modifier middlemanInstance {
        require(_middlemanFactory.isInstance(_id, msg.sender));
        _;
    }

    modifier middlemanAuthorized(address sender, string taskName) {
        require(_middlemanFactory.isInstance(_id, msg.sender));
        require(_middlemanAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier supplierAuthorized(address sender, string taskName) {
        require(_supplierFactory.isInstance(_id, msg.sender));
        require(_supplierAccess.isAuthorized(sender, taskName));
        _;
    }

    constructor(
        address localAccess,
        uint counter,
        address middlemanFactory, address middlemanAccess,
        address supplierFactory, address supplierAccess
    ) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;

        _middlemanFactory = MiddlemanFactory(middlemanFactory);
        _middlemanAccess = Access(middlemanAccess);
        _supplierFactory = SupplierFactory(supplierFactory);
        _supplierAccess = Access(supplierAccess);
    }
    
    function setSupplier(address supplier) public middlemanInstance {
        _supplier = Supplier(supplier);
    }

    function setManufacturer(address manufacturer) public middlemanInstance {
        _manufacturer = Manufacturer(manufacturer);
    }

    function receiveOrder(address sender) public middlemanAuthorized(sender, "receiveOrder") {
        emit OrderReceived();
    }

    function requestDetails() public localAuthorized("requestDetails") {
        _supplier.receiveRequest(msg.sender);
    }

    function receiveDetails(address sender) public supplierAuthorized(sender, "receiveDetails") {
        emit DetailsReceived();
    }

    function receiveWaybill(address sender) public supplierAuthorized(sender, "receiveWaybill") {
        emit WaybillReceived();
    }

    function deliverOrder() public localAuthorized("deliverOrder") {
        _manufacturer.receiveParts(msg.sender);
        selfdestruct(_factory);
    }
}

contract SpecialCarrierFactory {
    event SpecialCarrierInstanceCreated(address instanceAddress);

    address _accessAddress;
    mapping(uint => address) _instances;

    address _middlemanAddress = address(0);
    address _supplierAddress = address(0);

    modifier initialized {
        require(_middlemanAddress != address(0));
        require(_supplierAddress != address(0));
        _;
    }

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function setMiddleman(address middlemanAddress) public {
        _middlemanAddress = middlemanAddress;
    }
    
    function setSupplier(address supplierAddress) public {
        _supplierAddress = supplierAddress;
    }

    function createInstance(uint counter) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(_middlemanAddress);
        address middlemanAccess = middlemanFactory.getAccessAddress();
        
        SupplierFactory supplierFactory = SupplierFactory(_supplierAddress);
        address supplierAccess = supplierFactory.getAccessAddress();
        
        SpecialCarrier s = new SpecialCarrier(
            _accessAddress,
            counter,
            middlemanFactory, middlemanAccess,
            supplierFactory, supplierAccess);
        _instances[counter] = address(s);
        emit SpecialCarrierInstanceCreated(s);
        return s;
    }
}
