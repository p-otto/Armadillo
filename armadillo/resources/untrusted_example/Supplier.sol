pragma solidity ^0.4.24;

contract SpecialCarrier {
    function receiveDetails() public {}
    function receiveWaybill() public {}
}

contract MiddlemanFactory {
    function getAccessAddress() public returns(address) {}
}

contract SpecialCarrierFactory {
    function getAccessAddress() public returns(address) {}
}

contract Access {
    function isAuthorized(address, string) public returns(bool) {}
}

contract Supplier {
    event OrderReceived();
    event RequestReceived();
    event Selfdestructed();

    SpecialCarrier _specialCarrier;
    Access _specialCarrierAccess;
    Access _middlemanAccess;
    address _factory;

    modifier middlemanAuthorized(string taskName) {
        _middlemanAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    modifier specialCarrierAuthorized(string taskName) {
        _specialCarrierAccess.isAuthorized(msg.sender, taskName);
        _;
    }

    constructor(address specialCarrierAccess, address middlemanAccess) public {
        _factory = msg.sender;
        _specialCarrierAccess = Access(specialCarrierAccess);
        _middlemanAccess = Access(middlemanAccess);
    }

    function setSpecialCarrier(address specialCarrier) public middlemanAuthorized("setSpecialCarrier") {
        _specialCarrier = SpecialCarrier(specialCarrier);
    }

    function receiveOrder() public middlemanAuthorized("receiveOrder") {
        emit OrderReceived();
    }

    function receiveRequest() public specialCarrierAuthorized("receiveRequest") {
        emit RequestReceived();
    }

    function provideDetails() public {
        _specialCarrier.receiveDetails();
    }

    function provideWaybill() public {
        _specialCarrier.receiveWaybill();
        selfdestruct(_factory);
    }
}

contract SupplierFactory {
    event SupplierInstanceCreated(address instanceAddress);

    address _accessAddress;
    SpecialCarrierFactory _specialCarrierFactory;
    MiddlemanFactory _middlemanFactory;

    constructor(address accessAddress, address middlemanAddress, address specialCarrierAddress) public {
        _accessAddress = accessAddress;
        _middlemanFactory = MiddlemanFactory(middlemanAddress);
        _specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
    }

    function createInstance() public returns(address) {
        address specialCarrierAccess = _specialCarrierFactory.getAccessAddress();
        address middlemanAccess = _middlemanFactory.getAccessAddress();
        Supplier s = new Supplier(specialCarrierAccess, middlemanAccess);
        emit SupplierInstanceCreated(s);
        return s;
    }
}
