pragma solidity ^0.4.14;



contract Process_2_Contract {
    uint tokens = 2;
    address owner = 0;
    address parent = 0;
    uint subprocesses = 0;
    uint [] requestedID;
    event Element_Execution_Completed(uint elementId);
    Process_2_WorkList workList = new Process_2_WorkList();
    uint active_foo = 0;
    uint active_bar = 0;
    uint active_baz = 0;

    function Process_2_Contract() {
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
            Process_2_Contract(parent).handleGlobalErrorEnd(eventName);
        else
            tokens &= uint(~kill_Process_2());
     }

    function handleGlobalEscalationEnd(bytes32 eventName) {
        if (parent != 0)
            Process_2_Contract(parent).handleGlobalEscalationEnd(eventName);
     }

    function kill_Process_2() returns (uint) {
        uint tokensToKill = 0;
        tokensToKill |= uint(254);
        active_foo = 0;
        active_bar = 0;
        active_baz = 0;
        tokens &= uint(~tokensToKill);
        return 0;
    }

     function broadcastSignal_Process_2() {
        // Nothing to do ...
    }


    function foo_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.DefaultTask_start (this.foo_callback);
        active_foo |= uint(1) << reqId;
        return localTokens & uint(~2);
    }

    function foo_callback (uint reqId) returns (bool) {
        if (active_foo == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_foo & index == index) {
            active_foo &= ~index;

            step (tokens | 4);
            Element_Execution_Completed(1);
            return true;
        }
        return false ;
    }

    function ExclusiveGateway_1ozobgl(uint localTokens) internal returns (uint) {
        if (SequenceFlow_0g301p3)            return localTokens & uint(~4) | 8;
        else             return localTokens & uint(~4) | 16;
    }


    function bar_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.DefaultTask_start (this.bar_callback);
        active_bar |= uint(1) << reqId;
        return localTokens & uint(~8);
    }

    function bar_callback (uint reqId) returns (bool) {
        if (active_bar == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_bar & index == index) {
            active_bar &= ~index;

            step (tokens | 64);
            Element_Execution_Completed(4);
            return true;
        }
        return false ;
    }


    function baz_start (uint localTokens) internal returns (uint) {
        uint reqId = workList.DefaultTask_start (this.baz_callback);
        active_baz |= uint(1) << reqId;
        return localTokens & uint(~16);
    }

    function baz_callback (uint reqId) returns (bool) {
        if (active_baz == 0)
            return false;
        uint index = uint(1) << reqId;
        if(active_baz & index == index) {
            active_baz &= ~index;

            step (tokens | 32);
            Element_Execution_Completed(8);
            return true;
        }
        return false ;
    }

    function EndEvent_10y53g8(uint localTokens) internal returns (uint) {
        tokens = localTokens & uint(~128);
        if (tokens & 254 != 0) {
            return tokens;
        }
        if (parent != 0)
            Process_2_Contract(parent).handleGlobalDefaultEnd();
        Element_Execution_Completed(32);
        return tokens;
    }

    function step(uint localTokens) internal {
        bool done = false;
        while (!done) {
            if (localTokens & 2 == 2) {
                localTokens = foo_start(localTokens);
                continue;
            }
            if (localTokens & 4 != 0) {
                localTokens = ExclusiveGateway_1ozobgl(localTokens);
                continue;
            }
            if (localTokens & 8 == 8) {
                localTokens = bar_start(localTokens);
                continue;
            }
            if (localTokens & 16 == 16) {
                localTokens = baz_start(localTokens);
                continue;
            }
            if (localTokens & 96 != 0) {
                localTokens = localTokens & uint(~96) | 128;
                continue;
            }
            if (localTokens & 128 == 128) {
                localTokens = EndEvent_10y53g8(localTokens);
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
        if(active_foo != 0)
            flowNodes |= 1;
        if(active_bar != 0)
            flowNodes |= 4;
        if(active_baz != 0)
            flowNodes |= 8;

        return flowNodes;
    }

    function getWorkListAddress() returns (address) {
        return workList;
    }

    function getTaskRequestIndex(uint taskId) returns (uint) {
        if (taskId == 1)
            return active_foo;
        if (taskId == 4)
            return active_bar;
        if (taskId == 8)
            return active_baz;
    }

}



contract Process_2_WorkList {
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