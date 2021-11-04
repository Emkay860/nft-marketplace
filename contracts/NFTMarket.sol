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
    * @dev Cost of listng an item on our marketplace. value could be larger or small
    * depending on the blockchain
    */
    uint256 listingPrice = 0.035 ether;
    
    /** 
     * @dev A struct to to store market items listed
     * @note Possible addition of royalty feature to ensure initial creator income
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
        require(price > 0, "Price must be at least 1 wei");
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

        // Emit `MarketItemCreated` event once a new nft is successfully listed
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

    function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {

        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price, "Please submit the ask price in order to complete the purchase");
        // Transfer nft price to the seller
        idToMarketItem[itemId].seller.transfer(msg.value);
        // Transfer ownership of the nft from marketplace contract to the `msg.sender`
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        // Set the new owner of the nft to the msg.sender
        idToMarketItem[itemId].owner = payable(msg.sender);
        // Set item sold value to `true`
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();

        // Transfer listing price for the nft to the contract owner
        payable(owner).transfer(listingPrice);
    }

    /**
     * @dev This function fetches all items that have not being sold
     * i.e whose `idToMarketItem[itemId].sold` property is set to false
     * or `idToMarketItem[itemId].owner`is set to `address(0)`
     */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        // Create `items` of struct MarketItem and set the length to number of `unsoldItemCount`
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for(uint i = 0; i < itemCount; i++) {
            if(idToMarketItem[i+1].owner == address(0)) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }


    /**
     * @dev Gets all items where owner equals `msg.sender`
     */
    function fetchMyNFTs() public view returns (MarketItem[] memory){
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        // Iterate through the marketItems
        // and count the number of items for the current user i.e `msg.sender`
        for(uint i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i+1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        // Create an array of items with fixed length of items that belongs to `msg.sender` i.e `itemCount`
        MarketItem[] memory items = new MarketItem[](itemCount);

        // Iterate through all market items add items with owner equal `msg.sender` to a new array
        for (uint i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i+1].owner == msg.sender) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }


   /**
     * @dev Gets all items that a user created i.e seller equals `msg.sender`
     */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i+1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        
        for (uint i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i+1].seller == msg.sender) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        
        return items;
    }


}