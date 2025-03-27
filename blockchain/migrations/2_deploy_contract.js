const IncidentRegistry = artifacts.require("IncidentRegistry");

module.exports = function (deployer) {
  deployer.deploy(IncidentRegistry);
};
