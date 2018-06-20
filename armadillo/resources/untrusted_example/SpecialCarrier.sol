pragma solidity ^0.4.24;

contract Supplier {
    function receiveRequest() public {}
}

contract Manufacturer {
    function receiveParts() public {}
}

contract MiddlemanFactory {
    function getAccessAddress() public returns(address) {}
}

contract SupplierFactory {
    function getAccessAddress() public returns(address) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract SpecialCarrier {
    event OrderReceived();
    event DetailsReceived();
    event WaybillReceived();
    event Selfdestructed();

    Supplier _supplier;
    Manufacturer _manufacturer;
    Access _supplierAccess;
    Access _middlemanAccess;
    address _factory;

    modifier middlemanAuthorized(string taskName) {
        _middlemanAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    modifier supplierAuthorized(string taskName) {
        _supplierAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address middlemanAccess, address supplierAccess) public {
        _factory = msg.sender;
        _middlemanAccess = Access(middlemanAccess);
        _supplierAccess = Access(supplierAccess);
    }
    
    function setSupplier(address supplier) public middlemanAuthorized("setSupplier") {
        _supplier = Supplier(supplier);
    }

    function setManufacturer(address manufacturer) public middlemanAuthorized("setManufacturer") {
        _manufacturer = Manufacturer(manufacturer);
    }

    function receiveOrder() public middlemanAuthorized("receiveOrder") {
        emit OrderReceived();
    }

    function requestDetails() public {
        _supplier.receiveRequest();
    }

    function receiveDetails() public supplierAuthorized("receiveDetails") {
        emit DetailsReceived();
    }

    function receiveWaybill() public supplierAuthorized("receiveWaybill") {
        emit WaybillReceived();
    }

    function deliverOrder() public {
        _manufacturer.receiveParts();
        selfdestruct(_factory);
    }
}

contract SpecialCarrierFactory {
    event SpecialCarrierInstanceCreated(address instanceAddress);

    address _accessAddress;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(address middlemanAddress, address supplierAddress) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(middlemanAddress);
        SupplierFactory supplierFactory = SupplierFactory(supplierAddress);
        address middlemanAccess = middlemanFactory.getAccessAddress();
        address supplierAccess = supplierFactory.getAccessAddress();
        SpecialCarrier s = new SpecialCarrier(middlemanAccess, supplierAccess);
        emit SpecialCarrierInstanceCreated(s);
        return s;
    }
}
