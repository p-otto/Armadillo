pragma solidity ^0.4.24;

contract Supplier {
    function receiveRequest(address) public {}
}

contract Manufacturer {
    function receiveParts(address) public {}
}

contract Middleman {}

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
    Middleman _middleman;
    Access _localAccess;
    Access _supplierAccess;
    Access _middlemanAccess;
    address _factory;

    modifier middlemanAuthorized(address sender, string taskName) {
        require(msg.sender == address(_middleman));
        require(_middlemanAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier supplierAuthorized(address sender, string taskName) {
        require(msg.sender == address(_supplier));
        require(_supplierAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    constructor(address localAccess, address middlemanAccess, address supplierAccess) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _middlemanAccess = Access(middlemanAccess);
        _supplierAccess = Access(supplierAccess);
    }
    
    function setSupplier(address supplier) public middlemanAuthorized("setSupplier") {
        _supplier = Supplier(supplier);
    }

    function setManufacturer(address manufacturer) public middlemanAuthorized("setManufacturer") {
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
    MiddlemanFactory _middlemanFactory;
    SupplierFactory _supplierFactory;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(address middlemanAddress, address supplierAddress) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(middlemanAddress);
        SupplierFactory supplierFactory = SupplierFactory(supplierAddress);
        address middlemanAccess = middlemanFactory.getAccessAddress();
        address supplierAccess = supplierFactory.getAccessAddress();
        SpecialCarrier s = new SpecialCarrier(_accessAddress, middlemanAccess, supplierAccess);
        emit SpecialCarrierInstanceCreated(s);
        return s;
    }
}
