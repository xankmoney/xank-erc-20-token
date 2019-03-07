var XANK = artifacts.require("../contracts/XANK.sol");

module.exports = function(deployer) {
  deployer.deploy(XANK);
};
