require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const dotenv = require("dotenv");

dotenv.config();

const mnemonic = process.env.MNEMONIC.trim();
const infuraKey = process.env.INFURA_KEY;
const etherscanKey = process.env.ETHERSCAN_KEY;

module.exports = {
  networks: {
    localhost: {
      url: "http://localhost:7545",
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${infuraKey}`,
      accounts: {
        mnemonic,
      },
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${infuraKey}`,
      accounts: {
        mnemonic,
      },
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${infuraKey}`,
      accounts: {
        mnemonic,
      },
    },
  },
  etherscan: {
    apiKey: etherscanKey,
  },
  solidity: "0.8.4",
};