import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CoolNftModule = buildModule("CoolNftModule", (m) => {
  const coolNft = m.contract("CoolNft", []);

  return { coolNft };
});

export default CoolNftModule;

//address - 0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa
//link - https://sepolia-blockscout.lisk.com/address/0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa#code
