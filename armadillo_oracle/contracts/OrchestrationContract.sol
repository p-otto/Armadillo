pragma solidity ^0.4.17;

contract OrchestrationContract {
    event Order();

    constructor() {}

    function triggerOrder() {
        emit Order();
    }
}
