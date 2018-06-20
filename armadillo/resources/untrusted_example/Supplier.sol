pragma solidity ^0.4.24;

contract SpecialCarrier {
    function receiveDetails(address) public {}
    function receiveWaybill(address) public {}
}

contract Middleman {}

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
    Middleman _middleman;
    Access _localAccess;
    Access _specialCarrierAccess;
    Access _middlemanAccess;
    address _factory;

    modifier middlemanAuthorized(address sender, string taskName) {
        require(msg.sender == address(_middleman));
        require(_middlemanAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier specialCarrierAuthorized(address sender, string taskName) {
        require(msg.sender == address(_specialCarrier));
        require(_specialCarrierAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    constructor(address localAccess, address specialCarrierAccess, address middlemanAccess) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _specialCarrierAccess = Access(specialCarrierAccess);
        _middlemanAccess = Access(middlemanAccess);
    }

    function setSpecialCarrier(address specialCarrier) public middlemanAuthorized("setSpecialCarrier") {
        _specialCarrier = SpecialCarrier(specialCarrier);
    }

    function receiveOrder(address sender) public middlemanAuthorized(sender, "receiveOrder") {
        emit OrderReceived();
    }

    function receiveRequest(address sender) public specialCarrierAuthorized(sender, "receiveRequest") {
        emit RequestReceived();
    }

    function provideDetails() public localAuthorized("provideDetails") {
        _specialCarrier.receiveDetails(msg.sender);
    }

    function provideWaybill() public localAuthorized("provideWaybill") {
        _specialCarrier.receiveWaybill(msg.sender);
        selfdestruct(_factory);
    }
}

contract SupplierFactory {
    event SupplierInstanceCreated(address instanceAddress);

    address _accessAddress;
    SpecialCarrierFactory _specialCarrierFactory;
    MiddlemanFactory _middlemanFactory;

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function createInstance(address middlemanAddress, address specialCarrierAddress) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(middlemanAddress);
        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(specialCarrierAddress);
        address specialCarrierAccess = specialCarrierFactory.getAccessAddress();
        address middlemanAccess = middlemanFactory.getAccessAddress();
        Supplier s = new Supplier(_accessAddress, specialCarrierAccess, middlemanAccess);
        emit SupplierInstanceCreated(s);
        return s;
    }
}
