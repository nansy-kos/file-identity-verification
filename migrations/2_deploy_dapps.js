const FileIdentityVerification = artifacts.require('./FileIdentityVerification.sol');

module.exports = (deployer) => {
    deployer.deploy(FileIdentityVerification);
};
