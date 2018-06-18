pragma solidity ^0.4.24;

contract Supplier {
    function receiveOrder() public {}
    function setSpecialCarrier(address) public {}
}

contract SpecialCarrier {
    function receiveOrder() public {}
    function setManufacturer(address) public {}
    function setSupplier(address) public {}
}

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
    Access _manufacturerAccess;
    address _factory;

    modifier authorized(string taskName) {
        _manufacturerAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address supplierInstance, address specialCarrierInstance, address manufacturerAccess) public {
        _factory = msg.sender;
        _supplier = Supplier(supplierInstance);
        _specialCarrier = SpecialCarrier(specialCarrierInstance);
        _manufacturerAccess = Access(manufacturerAccess);
    }

    function setManufacturer(address manufacturer) public authorized("setManufacturer") {
        _specialCarrier.setManufacturer(manufacturer);
    }

    function receiveOrder() public authorized("receiveOrder") {
        emit OrderReceived();
    }

    function forwardOrder() public {
        _supplier.receiveOrder();
    }

    function orderTransport() public {
        _specialCarrier.receiveOrder();
        selfdestruct(_factory);
    }
}

contract MiddlemanFactory {
    event MiddlemanInstanceCreated(address instanceAddress);

    address _accessAddress;
    SupplierFactory _supplierFactory;
    SpecialCarrierFactory _specialCarrierFactory;
    ManufacturerFactory _manufacturerFactory;

    constructor(address accessAddress, address supplierAddress, address specialCarrierAddress, address manufacturerAddress) public {
        _accessAddress = accessAddress;
        _supplierFactory = SupplierFactory(supplierAddress);
        _specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
        _manufacturerFactory = ManufacturerFactory(manufacturerAddress);
    }

    function createInstance() public returns(address) {
        address supplierInstance = _supplierFactory.createInstance();
        address specialCarrierInstance = _specialCarrierFactory.createInstance();

        Supplier supplier = Supplier(supplierInstance);
        supplier.setSpecialCarrier(specialCarrierInstance);

        SpecialCarrier specialCarrier = SpecialCarrier(specialCarrierInstance);
        specialCarrier.setSupplier(supplierInstance);

        address manufacturerAccess = _manufacturerFactory.getAccessAddress();
        Middleman m = new Middleman(supplierInstance, specialCarrierInstance, manufacturerAccess);
        emit MiddlemanInstanceCreated(m);
        return m;
    }
}
