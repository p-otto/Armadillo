pragma solidity ^0.4.23;

contract SellerAccess {
    address owner;
    mapping(string => uint) roleToIndex;
    mapping(address => uint) addressToAccessBitmask;

    uint currentIndex = 1;

    constructor() public {
        owner = msg.sender;
    }

    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }

    function isAuthorized(address buyerAddress, string _role) public view returns(bool) {
        if (roleToIndex[_role] == 0) {
            return false;
        }

        uint roleIndex = roleToIndex[_role] - 1;

        return (addressToAccessBitmask[buyerAddress] & (1 << roleIndex)) != 0;
    }

    function giveRights(address _receiver, string _role) public only_owner {
        if (roleToIndex[_role] == 0) {
            roleToIndex[_role] = currentIndex;
            currentIndex += 1;
        }

        uint roleIndex = roleToIndex[_role] - 1;

        addressToAccessBitmask[_receiver] = addressToAccessBitmask[_receiver] | (1 << roleIndex);
    }

    function removeRights(address _receiver, string _role) public only_owner {
        uint roleIndex = roleToIndex[_role] - 1;

        addressToAccessBitmask[_receiver] = addressToAccessBitmask[_receiver] & ~(1 << roleIndex);
    }
}
