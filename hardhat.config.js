require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  networks: {
    localhost: {
      url: "http://localhost:7545",
    },
  },
  solidity: "0.8.4",
};