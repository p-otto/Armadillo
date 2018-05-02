pragma solidity ^0.4.14;
contract Oracle_Wrapper {
    function query_service (uint, uint, function (uint, uint) external returns (bool)) external returns (uint);
    function query_service (uint, function (uint, uint) external returns (bool)) external returns (uint);
}



contract BPM17_Running_Example_Contract {
    uint tokens = 2;
    address owner = 0;
    address parent = 0;
    uint subprocesses = 0;
    uint [] requestedID;
    event Loan_app_accepted_Mesage(bytes32 messageText);
    event Loan_app_rejected_Mesage(bytes32 messageText);
    event Confirmation_request_sent_Mesage(bytes32 messageText);
    event Element_Execution_Completed(uint elementId);
    BPM17_Running_Example_WorkList workList = new BPM17_Running_Example_WorkList();
    uint active_Enter_Loan_Application = 0;
    uint active_Confirm_Acceptance = 0;
    uint active_Assess_Elegibility = 0;
    mapping(uint => address) oracleAddresses;
    uint active_Assess_Loan_Risk = 0;
    uint active_Appraise_Property = 0;
    bool applicantEligible = false;
uint monthlyRevenue = 0;
uint loanAmount = 0;
uint cost = 0;
uint appraisePropertyResult = 0;
uint assessLoanRiskResult = 0;

    function BPM17_Running_Example_Contract() {
        owner = msg.sender;
        oracleAddresses[2] = $Assess_Loan_Risk_Address;
        oracleAddresses[4] = $Appraise_Property_Address;
        for (uint i = 0; i < 4; i++)
            requestedID.push(0);
        step(tokens);
    }

    function setParent(address newParent) {
        if (owner == msg.sender)
            parent = newParent;
    }

    function handleGlobalDefaultEnd() {
        // ................ Nothing to do ...........
    }

    function handleGlobalErrorEnd(bytes32 eventName) {
        if (parent != 0)
            BPM17_Running_Example_Contract(parent).handleGlobalErrorEnd(eventName);
        else
            tokens &= uint(~kill_BPM17_Running_Example());
     }

    function handleGlobalEscalationEnd(bytes32 eventName) {
        if (parent != 0)
            BPM17_Running_Example_Contract(parent).handleGlobalEscalationEnd(eventName);
     }

    function kill_BPM17_Running_Example() returns (uint) {
        uint tokensToKill = 0;
        tokensToKill |= uint(32766);
        active_Enter_Loan_Application = 0;
        active_Confirm_Acceptance = 0;
        active_Assess_Elegibility = 0;
        tokens &= uint(~tokensToKill);
        return 0;
    }

     function broadcastSignal_BPM17_Running_Example() {
        // Nothing to do ...
    }


    function Enter_Loan_Application_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.Enter_Loan_Application_start (this.Enter_Loan_Application_callback);
        active_Enter_Loan_Application |= uint(1) << reqId;
        return localTokens & uint(~2);
    }

    function Enter_Loan_Application_callback (uint reqId, uint _monthlyRevenue,uint _loanAmount,uint _cost) returns (bool) {
        if (active_Enter_Loan_Application == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_Enter_Loan_Application & index == index) {
            active_Enter_Loan_Application &= ~index;
            {monthlyRevenue = _monthlyRevenue; loanAmount = _loanAmount; cost = _cost; }
            step (tokens | 64);
            Element_Execution_Completed(1);
            return true;
        }
        return false ;
    }

    function Assess_Loan_Risk_start (uint localTokens) internal returns (uint) {

        uint reqId = Oracle_Wrapper(oracleAddresses[2]).query_service (monthlyRevenue,loanAmount, this.Assess_Loan_Risk_callbak);
        requestedID[1] |= uint(1) << reqId;
        return localTokens & uint(~128);
    }

    function Assess_Loan_Risk_callbak (uint reqId, uint _assessLoanRiskResult) external returns (bool) {
        uint localTokens = tokens;
        if (msg.sender != oracleAddresses[2])
            return false ;
        uint index = uint(1) << reqId;
        if(requestedID[1] & index == index) {
            {assessLoanRiskResult = _assessLoanRiskResult;}
            requestedID[1] &= ~uint(index);
            step (localTokens | 4);
            Element_Execution_Completed(2);
            return true;
        }
        return false ;
    }

    function Appraise_Property_start (uint localTokens) internal returns (uint) {

        uint reqId = Oracle_Wrapper(oracleAddresses[4]).query_service (cost, this.Appraise_Property_callbak);
        requestedID[2] |= uint(1) << reqId;
        return localTokens & uint(~512);
    }

    function Appraise_Property_callbak (uint reqId, uint _appraisePropertyResult) external returns (bool) {
        uint localTokens = tokens;
        if (msg.sender != oracleAddresses[4])
            return false ;
        uint index = uint(1) << reqId;
        if(requestedID[2] & index == index) {
            { appraisePropertyResult = _appraisePropertyResult;}
            requestedID[2] &= ~uint(index);
            step (localTokens | 1024);
            Element_Execution_Completed(4);
            return true;
        }
        return false ;
    }


    function Confirm_Acceptance_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.Confirm_Acceptance_start (this.Confirm_Acceptance_callback);
        active_Confirm_Acceptance |= uint(1) << reqId;
        return localTokens & uint(~16384);
    }

    function Confirm_Acceptance_callback (uint reqId, bool _confirmation) returns (bool) {
        if (active_Confirm_Acceptance == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_Confirm_Acceptance & index == index) {
            active_Confirm_Acceptance &= ~index;
            {applicantEligible = _confirmation; }
            step (tokens | 2048);
            Element_Execution_Completed(8);
            return true;
        }
        return false ;
    }

    function Assess_Elegibility(uint localTokens) internal returns (uint) {
        if (assessLoanRiskResult >= appraisePropertyResult)
    applicantEligible = true;
else
    applicantEligible = false;        Element_Execution_Completed(16);
        return localTokens & uint(~256) | 8;
    }

    function ExclusiveGateway_06dboho(uint localTokens) internal returns (uint) {
        if (applicantEligible)            return localTokens & uint(~8) | 16;
        else             return localTokens & uint(~8) | 32;
    }

    function Loan_app_accepted(uint localTokens) internal returns (uint) {
        tokens = localTokens & uint(~4096);
        if (tokens & 32766 != 0) {
            Loan_app_accepted_Mesage('Loan_app_accepted');
            return tokens;
        }
        if (parent != 0)
            BPM17_Running_Example_Contract(parent).handleGlobalDefaultEnd();
        Element_Execution_Completed(64);
        Loan_app_accepted_Mesage('Loan_app_accepted');
        return tokens;
    }

    function Loan_app_rejected(uint localTokens) internal returns (uint) {
        tokens = localTokens & uint(~8224);
        if (tokens & 32766 != 0) {
            Loan_app_rejected_Mesage('Loan_app_rejected');
            return tokens;
        }
        if (parent != 0)
            BPM17_Running_Example_Contract(parent).handleGlobalDefaultEnd();
        Element_Execution_Completed(128);
        Loan_app_rejected_Mesage('Loan_app_rejected');
        return tokens;
    }

    function ExclusiveGateway_0ga7p17(uint localTokens) internal returns (uint) {
        if (applicantEligible)            return localTokens & uint(~2048) | 4096;
        else             return localTokens & uint(~2048) | 8192;
    }

    function Confirmation_request_sent(uint localTokens) internal returns (uint) {
        Confirmation_request_sent_Mesage('Confirmation_request_sent');
       Element_Execution_Completed(2048);
        return localTokens & uint(~16) | 16384;
    }

    function step(uint localTokens) internal {
        bool done = false;
        while (!done) {
            if (localTokens & 2 == 2) {
                localTokens = Enter_Loan_Application_start(localTokens);
                continue;
            }
            if (localTokens & 128 == 128) {
                localTokens = Assess_Loan_Risk_start(localTokens);
                continue;
            }
            if (localTokens & 512 == 512) {
                localTokens = Appraise_Property_start(localTokens);
                continue;
            }
            if (localTokens & 16384 == 16384) {
                localTokens = Confirm_Acceptance_start(localTokens);
                continue;
            }
            if (localTokens & 256 == 256) {
                localTokens = Assess_Elegibility(localTokens);
                continue;
            }
            if (localTokens & 8 != 0) {
                localTokens = ExclusiveGateway_06dboho(localTokens);
                continue;
            }
            if (localTokens & 4096 == 4096) {
                localTokens = Loan_app_accepted(localTokens);
                continue;
            }
            if (localTokens & 8224 == 8224) {
                localTokens = Loan_app_rejected(localTokens);
                continue;
            }
            if (localTokens & 64 == 64) {
                localTokens = localTokens & uint(~64) | 640;
                continue;
            }
            if (localTokens & 1028 == 1028) {
                localTokens = localTokens & uint(~1028) | 256;
                continue;
            }
            if (localTokens & 2048 != 0) {
                localTokens = ExclusiveGateway_0ga7p17(localTokens);
                continue;
            }
            if (localTokens & 16 == 16) {
                localTokens = Confirmation_request_sent(localTokens);
                continue;
            }
            done = true;
        }
        tokens = localTokens;
    }

    function getRunningFlowNodes() returns (uint) {
        uint flowNodes = 0;
        uint localTokens = tokens;
        if(requestedID[1] != 0)
            flowNodes |= 2;
        if(requestedID[2] != 0)
            flowNodes |= 4;
        if(localTokens & 256 == 256)
            flowNodes |= 16;
        return flowNodes;
    }

    function getStartedFlowNodes() returns (uint) {
        uint flowNodes = 0;
        uint localTokens = tokens;
        if(active_Enter_Loan_Application != 0)
            flowNodes |= 1;
        if(localTokens & 128 == 128)
            flowNodes |= 2;
        if(localTokens & 512 == 512)
            flowNodes |= 4;
        if(active_Confirm_Acceptance != 0)
            flowNodes |= 8;
        if(active_Assess_Elegibility != 0)
            flowNodes |= 16;

        return flowNodes;
    }

    function getWorkListAddress() returns (address) {
        return workList;
    }

    function getTaskRequestIndex(uint taskId) returns (uint) {
        if (taskId == 1)
            return active_Enter_Loan_Application;
        if (taskId == 8)
            return active_Confirm_Acceptance;
        if (taskId == 16)
            return active_Assess_Elegibility;
    }

}



contract BPM17_Running_Example_WorkList {
    struct Enter_Loan_Application_Request {
        function (uint, uint, uint, uint) external returns (bool) callback;
    }
    Enter_Loan_Application_Request [] Enter_Loan_Application_requests;

    function Enter_Loan_Application_start (function (uint, uint, uint, uint) external returns (bool) callback) returns (uint) {
        uint index = Enter_Loan_Application_requests.length;
        Enter_Loan_Application_requests.push(Enter_Loan_Application_Request(callback));
        return index;
    }

    function Enter_Loan_Application_callback (uint reqId, uint _monthlyRevenue, uint _loanAmount, uint _cost) {
        Enter_Loan_Application_requests[reqId].callback(reqId, _monthlyRevenue, _loanAmount, _cost);
    }

    struct Confirm_Acceptance_Request {
        function (uint, bool) external returns (bool) callback;
    }
    Confirm_Acceptance_Request [] Confirm_Acceptance_requests;

    function Confirm_Acceptance_start (function (uint, bool) external returns (bool) callback) returns (uint) {
        uint index = Confirm_Acceptance_requests.length;
        Confirm_Acceptance_requests.push(Confirm_Acceptance_Request(callback));
        return index;
    }

    function Confirm_Acceptance_callback (uint reqId, bool _confirmation) {
        Confirm_Acceptance_requests[reqId].callback(reqId, _confirmation);
    }

}