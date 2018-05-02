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

contract Bitmask is Ownable {
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

    modifier role_require(string role) {
        require(checkAccessRights(role));
        _;
    }

    constructor() public {
        role_bit["lane1"] = 0x01;
        role_bit["lane2"] = 0x02;
        role_bit["superadmin"] = 0xFF;
        access_rights[owner] = access_rights[owner] | role_bit["superadmin"];
    }

    function giveRights(address _receiver, string _role) public only_owner {
        access_rights[_receiver] = access_rights[_receiver] | role_bit[_role];
    }

    function removeRights(address _receiver, string _role) public only_owner {
        access_rights[_receiver] = access_rights[_receiver] ^ role_bit[_role];
    }

    function checkAccessRights(string role) public view returns (bool) {
        return (access_rights[msg.sender] & role_bit[role]) != 0;
    }
}

contract BusinessProcess is Bitmask {
    uint _state;
    uint _final_state;

    event processAction(string action, address sender, uint next_state);

    constructor() public {
        _state = 0;
        _final_state = 4;
    }

    function action(string action_name, uint required_state, uint next_state, string lane) role_require(lane) internal {
        require(_state == required_state);
        _state = next_state;
        emit processAction(action_name, msg.sender, next_state);
        if(_state == _final_state) {
            selfdestruct(owner);
        }
    }

    function createDocument() public {
        action("createDocument", 0, 1, "lane1");
    }

    function approveDocument(bool approval) public {
        uint next_state = 0;
        if(approval) {
            next_state = 4;
        }   
        else {
            next_state = 3;
        }
        action("approveDocument", 1, next_state, "lane2");
    }

    function improveDocument() public {
        action("improveDocument", 3, 1, "lane1");
    }
}
