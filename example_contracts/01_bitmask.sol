pragma solidity ^0.4.23;

contract Ownable {
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }
    
    function changeOwner(address new_owner) only_owner public {
        owner = new_owner;
    }
}

contract Process is Ownable {
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        address delegate;
    }
    struct Proposal {
        uint voteCount;
    }

    mapping(string => uint) role_bit;
    mapping(address => uint) access_rights;

    event AccessRights(uint bitmask);

    constructor() public {
        role_bit["user"] = 0x01;
        role_bit["admin"] = 0x02;
        role_bit["superadmin"] = 0x04;
        access_rights[owner] = access_rights[owner] | role_bit["superadmin"];
    }

    function giveRights(address _receiver, string _role) public only_owner {
        access_rights[_receiver] = access_rights[_receiver] | role_bit[_role];
    }

    function removeRights(address _receiver, string _role) public only_owner {
        access_rights[_receiver] = access_rights[_receiver] ^ role_bit[_role];
    }

    function checkAccessRights(uint bit) public view returns (bool) {
        return (access_rights[msg.sender] & bit) != 0;
    }
}
