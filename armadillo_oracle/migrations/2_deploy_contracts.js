var OrchestrationContract = artifacts.require("./OrchestrationContract.sol");

module.exports = function(deployer) {
  deployer.deploy(OrchestrationContract);
};
