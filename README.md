# CoolNFTMarketplace

This repository contains the smart contracts source code, interaction scripts and unit test suites for CoolNftMarketplace. The repository uses Hardhat as development environment for compilation, testing and deployment tasks.

## What is CoolNftMarketplace

CoolNftMarketplace implements a NFT marketplace that allows users to list, sell and transfer ERC721 tokens (NFTs). It also allows the owner to add a NFT collection and give minting permit to other users.

## Contracts Documentation & Deployments

### [CoolNftMarketplace.sol](https://github.com/obah/cool-nft-marketplace/blob/main/contracts/CoolNftMarketplace.sol)

The `CoolNftMarketplace` contract provides functionality for minting, buying, selling, and transferring NFTs. It integrates with an ERC721 contract (CoolNft) and allows users with the "MINTER_ROLE" to mint NFTs. The contract also manages sales and marketplace transactions, including listing NFTs for sale, transferring ownership, and distributing transaction fees.

- Deployed address (Lisk Testnet): 0x546D42f8b00D3c885312bD31AFABaC4Ab621b349
- [Lisk Sepolia Blockscout verification link](https://sepolia-blockscout.lisk.com/address/0x546D42f8b00D3c885312bD31AFABaC4Ab621b349#code)

Key features:

- `NFT Minting`: Users with the `MINTER_ROLE` can mint new NFTs on the marketplace by paying a minting fee. The contract integrates with an external `CoolNft` ERC721 contract.
- `Marketplace for Buying and Selling`: The contract allows users to list their NFTs for sale and facilitates buying and selling between users. Sales are handled securely with ownership transfers and price payments.
- `Pseudorandom Token ID Assignment`: Each newly minted NFT is assigned a unique token ID, automatically incremented by the contract.
- `Secure Transfer of NFTs`: NFTs are safely transferred between addresses, ensuring that only the owner can transfer or list their NFTs for sale. The contract adheres to the `IERC721Receiver` interface for receiving NFTs.
- `Transaction Fee Management`: The marketplace charges a transaction fee on each NFT sale, which is stored in the contract’s balance. The owner can withdraw accumulated fees.
- `Role-Based Access Control`: The contract uses OpenZeppelin's `AccessControl` to manage minting privileges. Only users with the `MINTER_ROLE` can mint NFTs, and the owner can assign this role to others.
- `Event Emissions`: Key events such as minting, listing, buying, and transferring NFTs are emitted, making it easy to track actions on the marketplace.
- `Withdraw Functionality`: The contract owner can withdraw accumulated fees from the marketplace, ensuring proper management of transaction revenues.

Functions:

- `Constructor`: Sets the contract OWNER, assigns the `MINTER_ROLE`, and initializes the marketplace with the address of the CoolNft contract and a specified transaction fee.
- `mintNft(address _nftAddress, string memory _tokenURI)`: Mints a new NFT for the sender if they have the `MINTER_ROLE`. Requires a minting fee and emits an `NftMinted` event.
- `transferNft(uint256 _tokenId, address _nftAddress, address _to)`: Transfers an NFT from the current owner to a specified recipient. This function checks for ownership and emits an `NftTransfered` event.
- `sellNft(uint256 _tokenId, address _nftAddress, uint256 _price)`: Lists an NFT for sale. Transfers the NFT to the contract and stores the sale details in the `sales` mapping. Emits an `NftListed` event.
- `getNftListing(uint256 _listingId)`: Returns the details of a specific NFT listing.
- `buyNft(uint256 _listingId)`: Allows a user to purchase a listed NFT by paying the specified price. Handles the transfer of ownership and distribution of transaction fees. Emits an `NftBought` event.
- `withdraw(uint256 _amount)`: Allows the owner to withdraw accumulated transaction fees from the contract.
- `addMinter(address _account)`: Grants the `MINTER_ROLE` to a new account. Only the contract owner can call this function.
- `onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)`: A required function to enable the contract to safely receive ERC721 tokens.

### [CoolNft.sol](https://github.com/obah/cool-nft-marketplace/blob/main/contracts/CoolNft.sol)

This is the ERC721 contract for the NFT collection (CoolNFT) created and owned by the marketplace owner.

- Deployed address (Lisk testnet): 0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa
- [Lisk Sepolia Blockscout verification link](https://sepolia-blockscout.lisk.com/address/0x3F684E473Fc5e9202aA642062B25d0002fFf5bAa#code)

## Setup and Installation

### Prerequisites

Ensure you have the following installed:

- Node.js
- Hardhat

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/obah/cool-nft-marketplace.git
   cd cool-nft-marketplace
   ```

2. Install dependencies:
   ```
   npm install
   ```

## Test

To run the tests, use:

```
npx hardhat test
```
