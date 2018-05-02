/* Ownership - adds a modifier:
 * only the creator of the contract is allowed
 * to call the modified method.
 * Else: nothing will happen
 */
contract owned {
    address owner;

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    function owned() {
        owner = msg.sender;
    }
}


/*
 * Allows to manage rights to set certain variables;
 */
contract withRightManagement is owned {
    /* An associative array to hold the participants and their access rights */
    mapping(address => uint8) public rightsOfContributors;

    modifier contribution(uint8 _state) {
        require((rightsOfContributors[msg.sender] & _state) == _state);
        _;
    }

    function addContributor(address contributor, uint8 access) external onlyowner {
        rightsOfContributors[contributor] = access;
    }
}


contract DecisionCandrink {
	event Candrink(address instance, bool result);
	function decideCandrink(address _address) external {
		Statecandrink state = Statecandrink(_address);
		bool candrinkResult;
		
		if (state.age() < 18) {
			candrinkResult = false;

		}
		if (state.age() >= 18) {
			candrinkResult = true;

		}
		state.setCandrink(candrinkResult);
		Candrink(_address, candrinkResult);

	}
}

contract Statecandrink is withRightManagement {

	int32 public age;
	bool public candrink;
	uint8 public state;
	mapping(address => uint16) public accessRightsPerContributor;
	DecisionCandrink public decisionCandrink;

	function Statecandrink(address _decisionCandrink) public {
		decisionCandrink = DecisionCandrink(_decisionCandrink);
	}

	function setAge(int32 _age) external contribution(1) {
		age = _age;
		state |= 1;
		if (state & 2 != 2 && state & 1 == 1) {
			decisionCandrink.decideCandrink(this);
		}
	}

	function setCandrink(bool _candrink) external contribution(2) {
		candrink = _candrink;
		state |= 2;
		if (state & 2 != 2 && state & 1 == 1) {
			decisionCandrink.decideCandrink(this);
		}
	}
}

contract FactoryContract {
	address[] public contracts;
	address private decisionCandrinkRef;

	function getDecisionCandrink() public returns (address) {
		if (decisionCandrinkRef == address(0)) {
			decisionCandrinkRef = new DecisionCandrink();
		}
		return decisionCandrinkRef;

	}

	function createContract() public returns (address) {
		contracts.push(new Statecandrink(getDecisionCandrink()));
		Statecandrink state = Statecandrink(contracts[contracts.length - 1]);
		state.addContributor(12345, 1);
		state.addContributor(decisionCandrinkRef, 2);
		return contracts[contracts.length - 1];
	}
}
