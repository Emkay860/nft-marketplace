require("@nomiclabs/hardhat-waffle");
const fs = require("fs");

const privateKey = fs.readFileSync(".secret").toString();
const projectId = "evXVt1m95dXpPeuei7XR7IDSJmW0Dv1sOW7xA6yh";

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: `https://rnl9tzxcm93a.usemoralis.com:2053/server/${projectId}`,
      accounts: [privateKey]
    },
  },
  solidity: "0.8.4",
};
