import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const COOL_NFT_ADDRESS = "0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa";
const TRANSACTION_FEE: bigint = 5_000_000_000_000n;

const CoolNftMarketplaceModule = buildModule(
  "CoolNftMarketplaceModule",
  (m) => {
    const nftAddress = m.getParameter("_nftAddress", COOL_NFT_ADDRESS);
    const transactionFee = m.getParameter("_transactionFee", TRANSACTION_FEE);

    const coolNftMarketplace = m.contract("CoolNftMarketplace", [
      nftAddress,
      transactionFee,
    ]);

    return { coolNftMarketplace };
  }
);

export default CoolNftMarketplaceModule;
