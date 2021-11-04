// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    /** 
    * @dev cost of listng an item on our marketplace. value could be larger or small
    *      depending on the blockchain
    */
    uint256 listingPrice = 0.035 ether;
    
    /** 
     * @dev A struct to to store market items listed
     * @note possible addition of royalty feature to ensure initial creator income
     */
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    /** 
     * @dev An event emitted whenever a new Item is listed
     */
    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor(){
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        // Transfer ownership of nft from the seller to the marketplace contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // emit `MarketItemCreated` event once a new nft is successfully listed
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

}