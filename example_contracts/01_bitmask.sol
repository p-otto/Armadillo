pragma solidity ^0.4.0;

contract Process {

    uint USER_BIT = 0x01;
    uint ADMIN_BIT = 0x02;
    uint SUPERADMIN_BIT = 0x04;

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        address delegate;
    }
    struct Proposal {
        uint voteCount;
    }

    address process_owner;
    mapping(address => uint) access_rights;

    event AccessRights(uint bitmask);

    constructor() {
        process_owner = msg.sender;
        access_rights[process_owner] = access_rights[process_owner] | SUPERADMIN_BIT;
    }

    function giveRights(address _receiver, uint _bit) {
        access_rights[_receiver] = access_rights[_receiver] | _bit;
    }

    function checkAccessRights(uint bit) returns (bool) {
        return (access_rights[msg.sender] & bit) != 0;
    }
}