const AxyToken = artifacts.require("AxyToken");

module.exports = async function (deployer,network,accounts) {
  await deployer.deploy(AxyToken);
};
