// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface ICoolNft is IERC721 {
    function mintNFT(
        address _recipient,
        string memory _tokenURI,
        uint256 _tokenId
    ) external;
}

contract CoolNftMarketplace is AccessControl, IERC721Receiver {
    event NftMinted(address indexed to, uint256 indexed tokenId);
    event NftBought(
        address indexed buyer,
        address indexed seller,
        address nft,
        uint256 indexed tokenId
    );
    event NftListed(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 price
    );
    event NftTransfered(
        address indexed owner,
        address indexed to,
        address indexed nft,
        uint256 tokenId
    );

    error InvalidAddress();
    error InsufficientAmount();
    error UnathorizedAccess();

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 counter;
    uint256 mintFee = 5e17; //0.5 eth to mint an NFT

    ICoolNft immutable COOLNFT;

    address immutable OWNER;

    struct NftListing {
        address nft;
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isSold;
    }

    constructor(address _nftAddress) {
        OWNER = msg.sender;

        _grantRole(MINTER_ROLE, msg.sender);

        COOLNFT = ICoolNft(_nftAddress);
    }

    function mintNft(
        address _nftAddress,
        uint256 _amount,
        string memory _tokenURI
    ) external onlyRole(MINTER_ROLE) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_nftAddress == address(0)) revert InvalidAddress();
        if (_amount < mintFee) revert InsufficientAmount();

        counter = counter + 1;

        COOLNFT.mintNFT(msg.sender, _tokenURI, counter);

        emit NftMinted(msg.sender, counter);
    }

    function transferNft(
        uint256 _tokenId,
        address _nftAddress,
        address _to
    ) private {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_nftAddress == address(0)) revert InvalidAddress();
        if (_to == address(0)) revert InvalidAddress();

        IERC721 _nft = IERC721(_nftAddress);
        address _owner = _nft.ownerOf(_tokenId);

        if (msg.sender != _owner) revert UnathorizedAccess();

        _nft.safeTransferFrom(msg.sender, _to, _tokenId);
    }

    function sellNft() external {}

    function buyNft() external {}

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
