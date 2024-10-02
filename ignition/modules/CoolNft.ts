import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CoolNftModule = buildModule("CoolNftModule", (m) => {
  const coolNft = m.contract("CoolNft", []);

  return { coolNft };
});

export default CoolNftModule;
