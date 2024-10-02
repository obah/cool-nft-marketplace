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
    error TransactionFailed();
    error AlreadyAMinter();

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 counter;
    uint256 mintFee = 5e17; //0.5 eth to mint an NFT
    uint256 immutable TRANSACTION_FEE;
    uint256 public balance;

    ICoolNft immutable COOLNFT;

    address immutable OWNER;

    struct NftListing {
        address nft;
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isSold;
    }

    mapping(uint256 => NftListing) public sales;

    constructor(address _nftAddress, uint256 _transactionFee) {
        OWNER = msg.sender;

        _grantRole(MINTER_ROLE, msg.sender);

        COOLNFT = ICoolNft(_nftAddress);
        TRANSACTION_FEE = _transactionFee;
    }

    receive() external payable {}

    function mintNft(
        address _nftAddress,
        string memory _tokenURI
    ) external payable onlyRole(MINTER_ROLE) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_nftAddress == address(0)) revert InvalidAddress();
        if (msg.value < mintFee) revert InsufficientAmount();

        counter = counter + 1;

        COOLNFT.mintNFT(msg.sender, _tokenURI, counter);

        emit NftMinted(msg.sender, counter);
    }

    function transferNft(
        uint256 _tokenId,
        address _nftAddress,
        address _to
    ) private returns (bool transferred_) {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_nftAddress == address(0)) revert InvalidAddress();
        if (_to == address(0)) revert InvalidAddress();

        IERC721 _nft = IERC721(_nftAddress);
        address _owner = _nft.ownerOf(_tokenId);

        if (msg.sender != _owner) revert UnathorizedAccess();

        _nft.safeTransferFrom(msg.sender, _to, _tokenId);

        transferred_ = true;

        emit NftTransfered(msg.sender, _to, _nftAddress, _tokenId);
    }

    function sellNft(
        uint256 _tokenId,
        address _nftAddress,
        uint256 _price
    ) external {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_nftAddress == address(0)) revert InvalidAddress();

        IERC721 _nft = IERC721(_nftAddress);
        address _owner = _nft.ownerOf(_tokenId);

        if (msg.sender != _owner) revert UnathorizedAccess();

        bool transfer = transferNft(_tokenId, _nftAddress, address(this));
        if (!transfer) revert TransactionFailed();

        counter = counter + 1;

        NftListing storage sale = sales[counter];

        sale.nft = _nftAddress;
        sale.seller = msg.sender;
        sale.tokenId = _tokenId;
        sale.price = _price;

        emit NftListed(msg.sender, _nftAddress, _tokenId, _price);
    }

    function getNftListing(
        uint256 _listingId
    ) external view returns (NftListing memory) {
        return sales[_listingId];
    }

    function buyNft(uint256 _listingId) external payable {
        if (msg.sender == address(0)) revert InvalidAddress();

        NftListing storage listing = sales[_listingId];

        if (msg.value < listing.price) revert InsufficientAmount();

        listing.isSold = true;

        uint256 _sellerFee = msg.value - TRANSACTION_FEE;

        (bool feePaid, ) = address(this).call{value: TRANSACTION_FEE}("");
        if (!feePaid) revert TransactionFailed();

        balance = balance + TRANSACTION_FEE;

        (bool pricePaid, ) = listing.seller.call{value: _sellerFee}("");
        if (!pricePaid) revert TransactionFailed();

        bool transfer = transferNft(listing.tokenId, address(this), msg.sender);
        if (!transfer) revert TransactionFailed();

        emit NftBought(
            msg.sender,
            listing.seller,
            listing.nft,
            listing.tokenId
        );
    }

    function withdraw(uint256 _amount) external {
        if (msg.sender == address(0)) revert InvalidAddress();
        if (msg.sender != OWNER) revert UnathorizedAccess();
        if (_amount > balance) revert InsufficientAmount();

        (bool sent, ) = OWNER.call{value: _amount}("");
        if (!sent) revert TransactionFailed();

        balance = balance - _amount;
    }

    function addMinter(address _account) external {
        if (msg.sender != OWNER) revert UnathorizedAccess();
        if (msg.sender == address(0)) revert InvalidAddress();
        if (_account == address(0)) revert InvalidAddress();
        if (hasRole(MINTER_ROLE, _account)) revert AlreadyAMinter();

        grantRole(MINTER_ROLE, _account);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
