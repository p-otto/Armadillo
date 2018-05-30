var SellerContract = artifacts.require("SellerContract");
var BuyerContract = artifacts.require("BuyerContract");

module.exports = function(deployer) {
  deployer.deploy(SellerContract);
  deployer.deploy(BuyerContract);
};
