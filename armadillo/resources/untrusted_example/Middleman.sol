pragma solidity ^0.4.24;

contract Supplier {
    function receiveOrder(address) public {}
    function setSpecialCarrier(address) public {}
}

contract SpecialCarrier {
    function receiveOrder(address) public {}
    function setManufacturer(address) public {}
    function setSupplier(address) public {}
}

contract Manufacturer {}

contract SupplierFactory {
    function createInstance() public returns(address) {}
}

contract SpecialCarrierFactory {
    function createInstance() public returns(address) {}
}

contract ManufacturerFactory {
    function getAccessAddress() public returns(address) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract Middleman {
    event OrderReceived();
    event Selfdestructed();

    Supplier _supplier;
    SpecialCarrier _specialCarrier;
    Manufacturer _manufacturer;
    Access _manufacturerAccess;
    Access _localAccess;
    address _factory;

    modifier manufacturerAuthorized(address sender, string taskName) {
        require(msg.sender == address(_manufacturer));
        require(_manufacturerAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
    }

    constructor(address localAccess, address supplierInstance, address specialCarrierInstance, address manufacturerAccess) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _supplier = Supplier(supplierInstance);
        _specialCarrier = SpecialCarrier(specialCarrierInstance);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function setManufacturer(address manufacturer) public manufacturerAuthorized("setManufacturer") {
        _manufacturer = Manufacturer(manufacturer);
        _specialCarrier.setManufacturer(manufacturer);
    }

    function receiveOrder(address sender) public manufacturerAuthorized(sender, "receiveOrder") {
        emit OrderReceived();
    }

    function forwardOrder() public localAuthorized("forwardOrder") {
        _supplier.receiveOrder(msg.sender);
    }

    function orderTransport() public localAuthorized("orderTransport") {
        _specialCarrier.receiveOrder(msg.sender);
        selfdestruct(_factory);
    }
}

contract MiddlemanFactory {
    event MiddlemanInstanceCreated(address instanceAddress);

    address _accessAddress;
    SupplierFactory _supplierFactory;
    SpecialCarrierFactory _specialCarrierFactory;
    ManufacturerFactory _manufacturerFactory;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(address supplierAddress, address specialCarrierAddress, address manufacturerAddress) public returns(address) {
        SupplierFactory supplierFactory = SupplierFactory(supplierAddress);
        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
        ManufacturerFactory manufacturerFactory = ManufacturerFactory(manufacturerAddress);

        address supplierInstance = supplierFactory.createInstance();
        address specialCarrierInstance = specialCarrierFactory.createInstance();

        Supplier supplier = Supplier(supplierInstance);
        supplier.setSpecialCarrier(specialCarrierInstance);

        SpecialCarrier specialCarrier = SpecialCarrier(specialCarrierInstance);
        specialCarrier.setSupplier(supplierInstance);

        address manufacturerAccess = manufacturerFactory.getAccessAddress();
        Middleman m = new Middleman(_accessAddress, supplierInstance, specialCarrierInstance, manufacturerAccess);
        emit MiddlemanInstanceCreated(m);
        return m;
    }
}
