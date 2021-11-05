require("@nomiclabs/hardhat-waffle");
const fs = require("fs");

const privateKey = fs.readFileSync(".secret").toString();
const projectId = "583d94e4544e458eb60bda422e005d49";

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey]
    },
  },
  solidity: "0.8.4",
};
