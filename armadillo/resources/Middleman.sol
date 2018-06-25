pragma solidity ^0.4.24;

contract Supplier {
    function receiveOrder(address) public;
    function setSpecialCarrier(address) public;
}

contract SpecialCarrier {
    function receiveOrder(address) public;
    function setManufacturer(address) public;
    function setSupplier(address) public;
}

contract SupplierFactory {
    function createInstance(uint) public returns(address);
}

contract SpecialCarrierFactory {
    function createInstance(uint) public returns(address);
}

contract ManufacturerFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract Access {
    function isAuthorized(address, string) public returns(bool);
}

contract Middleman {
    event OrderReceived();
    event Selfdestructed();

    address _factory;
    Access _localAccess;
    uint _id;

    Supplier _supplier;
    SpecialCarrier _specialCarrier;
    ManufacturerFactory _manufacturerFactory;
    Access _manufacturerAccess;
    address _manufacturer;

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    modifier manufacturerAuthorized(address sender, string taskName) {
        require(_manufacturerFactory.isInstance(_id, msg.sender));
        require(_manufacturerAccess.isAuthorized(sender, taskName));
        _;
    }

    constructor(
        address localAccess,
        uint counter,
        address supplierInstance,
        address specialCarrierInstance,
        address manufacturerFactory, address manufacturerAccess
    ) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;

        _supplier = Supplier(supplierInstance);
        _specialCarrier = SpecialCarrier(specialCarrierInstance);
        _manufacturerFactory = ManufacturerFactory(manufacturerFactory);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function receiveOrder(address sender) public manufacturerAuthorized(sender, "receiveOrder") {
        _manufacturer = msg.sender;
        emit OrderReceived();
    }

    function forwardOrder() public localAuthorized("receiveOrder") {
        _supplier.receiveOrder(msg.sender);
    }

    function orderTransport() public localAuthorized("receiveOrder") {
        _specialCarrier.setSupplier(_supplier);
        _specialCarrier.setManufacturer(_manufacturer);
        _specialCarrier.receiveOrder(msg.sender);
        selfdestruct(_factory);
    }
}

contract MiddlemanFactory {
    event MiddlemanInstanceCreated(address instanceAddress);

    address _accessAddress;
    mapping(uint => address) _instances;

    address _manufacturerAddress = address(0);
    address _supplierAddress = address(0);
    address _specialCarrierAddress = address(0);

    modifier initialized {
        require(_manufacturerAddress != address(0));
        require(_supplierAddress != address(0));
        require(_specialCarrierAddress != address(0));
        _;
    }

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function setManufacturer(address manufacturerAddress) public {
        _manufacturerAddress = manufacturerAddress;
    }
    
    function setSupplier(address supplierAddress) public {
        _supplierAddress = supplierAddress;
    }
    
    function setSpecialCarrier(address specialCarrierAddress) public {
        _specialCarrierAddress = specialCarrierAddress;
    }

    function createInstance(uint counter) public initialized returns(address) {
        SupplierFactory supplierFactory = SupplierFactory(_supplierAddress);
        address supplierInstance = supplierFactory.createInstance(counter);
        
        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(_specialCarrierAddress);
        address specialCarrierInstance = specialCarrierFactory.createInstance(counter);
        
        ManufacturerFactory manufacturerFactory = ManufacturerFactory(_manufacturerAddress);
        address manufacturerAccess = manufacturerFactory.getAccessAddress();

        Middleman m = new Middleman(
            _accessAddress,
            counter,
            supplierInstance,
            specialCarrierInstance,
            manufacturerFactory, manufacturerAccess);
        _instances[counter] = address(m);
        emit MiddlemanInstanceCreated(m);
        return m;
    }

    function isInstance(uint id, address instanceAddress) public view returns(bool) {
        return _instances[id] == instanceAddress;
    }

    function getAccessAddress() public view returns(address) {
        return _accessAddress;
    }
}
