pragma solidity ^0.4.14;



contract Process_1_Contract {
    uint tokens = 2;
    address owner = 0;
    address parent = 0;
    uint subprocesses = 0;
    uint [] requestedID;
    event Element_Execution_Completed(uint elementId);
    Process_1_WorkList workList = new Process_1_WorkList();
    uint active_Wake_up = 0;
    uint active_Stand_up = 0;

    function Process_1_Contract() {
        owner = msg.sender;
        for (uint i = 0; i < 0; i++)
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
            Process_1_Contract(parent).handleGlobalErrorEnd(eventName);
        else
            tokens &= uint(~kill_Process_1());
     }

    function handleGlobalEscalationEnd(bytes32 eventName) {
        if (parent != 0)
            Process_1_Contract(parent).handleGlobalEscalationEnd(eventName);
     }

    function kill_Process_1() returns (uint) {
        uint tokensToKill = 0;
        tokensToKill |= uint(14);
        active_Wake_up = 0;
        active_Stand_up = 0;
        tokens &= uint(~tokensToKill);
        return 0;
    }

     function broadcastSignal_Process_1() {
        // Nothing to do ...
    }


    function Wake_up_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.Wake_up_start (this.Wake_up_callback);
        active_Wake_up |= uint(1) << reqId;
        return localTokens & uint(~2);
    }

    function Wake_up_callback (uint reqId, uint _sleepiness) returns (bool) {
        if (active_Wake_up == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_Wake_up & index == index) {
            active_Wake_up &= ~index;
            {sleepiness = _sleepiness;}
            step (tokens | 4);
            Element_Execution_Completed(1);
            return true;
        }
        return false ;
    }


    function Stand_up_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.DefaultTask_start (this.Stand_up_callback);
        active_Stand_up |= uint(1) << reqId;
        return localTokens & uint(~4);
    }

    function Stand_up_callback (uint reqId) returns (bool) {
        if (active_Stand_up == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_Stand_up & index == index) {
            active_Stand_up &= ~index;

            step (tokens | 8);
            Element_Execution_Completed(2);
            return true;
        }
        return false ;
    }

    function EndEvent_08iu52z(uint localTokens) internal returns (uint) {
        tokens = localTokens & uint(~8);
        if (tokens & 14 != 0) {
            return tokens;
        }
        if (parent != 0)
            Process_1_Contract(parent).handleGlobalDefaultEnd();
        Element_Execution_Completed(4);
        return tokens;
    }

    function step(uint localTokens) internal {
        bool done = false;
        while (!done) {
            if (localTokens & 2 == 2) {
                localTokens = Wake_up_start(localTokens);
                continue;
            }
            if (localTokens & 4 == 4) {
                localTokens = Stand_up_start(localTokens);
                continue;
            }
            if (localTokens & 8 == 8) {
                localTokens = EndEvent_08iu52z(localTokens);
                continue;
            }
            done = true;
        }
        tokens = localTokens;
    }

    function getRunningFlowNodes() returns (uint) {
        uint flowNodes = 0;
        uint localTokens = tokens;
        return flowNodes;
    }

    function getStartedFlowNodes() returns (uint) {
        uint flowNodes = 0;
        uint localTokens = tokens;
        if(active_Wake_up != 0)
            flowNodes |= 1;
        if(active_Stand_up != 0)
            flowNodes |= 2;

        return flowNodes;
    }

    function getWorkListAddress() returns (address) {
        return workList;
    }

    function getTaskRequestIndex(uint taskId) returns (uint) {
        if (taskId == 1)
            return active_Wake_up;
        if (taskId == 2)
            return active_Stand_up;
    }

}



contract Process_1_WorkList {
    struct Wake_up_Request {
        function (uint, uint) external returns (bool) callback;
    }
    Wake_up_Request [] Wake_up_requests;

    function Wake_up_start (function (uint, uint) external returns (bool) callback) returns (uint) {
        uint index = Wake_up_requests.length;
        Wake_up_requests.push(Wake_up_Request(callback));
        return index;
    }

    function Wake_up_callback (uint reqId, uint _sleepiness) {
        Wake_up_requests[reqId].callback(reqId, _sleepiness);
    }

    struct DefaultTask_Request {
        function (uint) external returns (bool) callback;
    }
    DefaultTask_Request [] DefaultTask_requests;

    function DefaultTask_start (function (uint) external returns (bool) callback) returns (uint) {
        uint index = DefaultTask_requests.length;
        DefaultTask_requests.push(DefaultTask_Request(callback));
        return index;
    }

    function DefaultTask_callback (uint reqId) {
        DefaultTask_requests[reqId].callback(reqId);
    }

}