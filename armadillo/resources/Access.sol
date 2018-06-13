pragma solidity ^0.4.23;

contract Access {
    address owner;
    mapping(string => uint) roleToIndex;
    mapping(address => uint) addressToAccessBitmask;
    mapping(string => string) taskToRole;

    uint currentIndex = 1;

    constructor() public {
        owner = msg.sender;
    }

    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }

    function isAuthorized(address buyerAddress, string _taskName) public view returns(bool) {
        if (bytes(taskToRole[_taskName]).length == 0) {
            return false;
        }
        
        if (roleToIndex[taskToRole[_taskName]] == 0) {
            return false;
        }

        uint roleIndex = roleToIndex[taskToRole[_taskName]] - 1;

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

    function assignRole(string _taskName, string _role) public only_owner {
        taskToRole[_taskName] = _role;
    }

    function unassignRole(string _taskName) public only_owner {
        taskToRole[_taskName] = "";
    }
}
