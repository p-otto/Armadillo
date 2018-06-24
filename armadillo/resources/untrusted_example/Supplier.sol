pragma solidity ^0.4.24;

contract SpecialCarrier {
    function receiveDetails(address) public;
    function receiveWaybill(address) public;
}

contract MiddlemanFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract SpecialCarrierFactory {
    function getAccessAddress() public returns(address);
    function isInstance(uint id, address instanceAddress) public view returns(bool);
}

contract Access {
    function isAuthorized(address, string) public returns(bool);
}

contract Supplier {
    event OrderReceived();
    event RequestReceived();
    event Selfdestructed();

    address _factory;
    Access _localAccess;
    uint _id;

    SpecialCarrierFactory _specialCarrierFactory;
    Access _specialCarrierAccess;
    SpecialCarrier _specialCarrier;
    MiddlemanFactory _middlemanFactory;
    Access _middlemanAccess;

    modifier localAuthorized(string taskName) {
        require(_localAccess.isAuthorized(msg.sender, taskName));
        _;
    }

    modifier middlemanAuthorized(address sender, string taskName) {
        require(_middlemanFactory.isInstance(_id, msg.sender));
        require(_middlemanAccess.isAuthorized(sender, taskName));
        _;
    }

    modifier specialCarrierAuthorized(address sender, string taskName) {
        require(msg.sender == address(_specialCarrier));
        require(_specialCarrierAccess.isAuthorized(sender, taskName));
        _;
    }

    constructor(
        address localAccess,
        uint counter,
        address specialCarrierFactory, address specialCarrierAccess,
        address middlemanFactory, address middlemanAccess
    ) public {
        _factory = msg.sender;
        _localAccess = Access(localAccess);
        _id = counter;

        _specialCarrierFactory = SpecialCarrierFactory(specialCarrierFactory);
        _specialCarrierAccess = Access(specialCarrierAccess);
        _middlemanFactory = MiddlemanFactory(middlemanFactory);
        _middlemanAccess = Access(middlemanAccess);
    }

    function receiveOrder(address sender) public middlemanAuthorized(sender, "receiveOrder") {
        emit OrderReceived();
    }

    function receiveRequest(address sender) public specialCarrierAuthorized(sender, "receiveRequest") {
        _specialCarrier = SpecialCarrier(msg.sender);
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
    mapping(uint => address) _instances;

    address _middlemanAddress = address(0);
    address _specialCarrierAddress = address(0);

    modifier initialized {
        require(_middlemanAddress != address(0));
        require(_specialCarrierAddress != address(0));
        _;
    }

    constructor(address accessAddress) public {
        _accessAddress = accessAddress;
    }

    function setMiddleman(address middlemanAddress) public {
        _middlemanAddress = middlemanAddress;
    }
    
    function setSpecialCarrier(address specialCarrierAddress) public {
        _specialCarrierAddress = specialCarrierAddress;
    }

    function createInstance(uint counter) public returns(address) {
        MiddlemanFactory middlemanFactory = MiddlemanFactory(_middlemanAddress);
        address middlemanAccess = middlemanFactory.getAccessAddress();

        SpecialCarrierFactory specialCarrierFactory = SpecialCarrierFactory(_specialCarrierAddress);
        address specialCarrierAccess = specialCarrierFactory.getAccessAddress();

        Supplier s = new Supplier(
            _accessAddress,
            counter,
            specialCarrierFactory, specialCarrierAccess,
            middlemanFactory, middlemanAccess);
        _instances[counter] = address(s);
        emit SupplierInstanceCreated(s);
        return s;
    }

    function isInstance(uint id, address instanceAddress) public view returns(bool) {
        return _instances[id] == instanceAddress;
    }
}
