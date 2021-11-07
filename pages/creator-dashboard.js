import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import Web3Modal from 'web3modal';
import axios from 'axios';

import MyNFTs from '../components/my-assets';

import { nftaddress, nftmarketaddress } from '../config';

import NFT from '../artifacts/contracts/NFT.sol/NFT.json';
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json';

export default function CreatorDashboard() {
  const [nfts, setNfts] = useState([]);
  const [purchasedNfts, setPurchasedNfts] = useState([]);
  const [sold, setSold] = useState([]);
  const [loadingState, setLoadingState] = useState('not-loaded');

  useEffect(() => {
    loadNFTs();
  }, []);

  async function loadNFTs() {
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();

    const marketContract = new ethers.Contract(
      nftmarketaddress,
      Market.abi,
      signer
    );
    const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
    const data = await marketContract.fetchItemsCreated();

    const items = await Promise.all(
      data.map(async (i) => {
        const tokenUri = await tokenContract.tokenURI(i.tokenId);
        const meta = await axios.get(tokenUri);
        let price = ethers.utils.formatUnits(i.price.toString(), 'ether');
        let item = {
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          sold: i.sold,
          image: meta.data.image,
        };
        return item;
      })
    );
    /* create a filtered array of items that have been sold */
    const soldItems = items.filter((i) => i.sold);
    setSold(soldItems);
    setNfts(items);
    setLoadingState('loaded');

    // load all purchased NFTs
    loadPurchasedNFTs(provider, signer);
  }

  // this function loads all nfts purchased by current user
  async function loadPurchasedNFTs(provider, signer) {
    const marketContract = new ethers.Contract(
      nftmarketaddress,
      Market.abi,
      signer
    );
    const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
    const data = await marketContract.fetchMyNFTs();

    const items = await Promise.all(
      data.map(async (i) => {
        const tokenUri = await tokenContract.tokenURI(i.tokenId);
        const meta = await axios.get(tokenUri);
        let price = ethers.utils.formatUnits(i.price.toString(), 'ether');
        let item = {
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          image: meta.data.image,
        };
        return item;
      })
    );
    setPurchasedNfts(items);
    setLoadingState('loaded');
  }

  if (loadingState === 'loaded' && !nfts.length)
    return <h1 className="py-10 px-20 text-3xl">No assets created</h1>;
  return (
    <div>
      <div className="p-4">
        <h2 className="text-2xl py-2">Items Created</h2>
        <MyNFTs loadingState={loadingState} nfts={nfts} />
      </div>
      <div className="px-4">
        {Boolean(sold.length) && (
          <div>
            <h2 className="text-2xl py-2">Items sold</h2>
            <MyNFTs loadingState={loadingState} nfts={sold} />
          </div>
        )}
      </div>

      <div className="px-4">
        {Boolean(purchasedNfts.length) && (
          <div>
            <h2 className="text-2xl py-2">Items Puchased</h2>
            <MyNFTs loadingState={loadingState} nfts={purchasedNfts} />
          </div>
        )}
      </div>
    </div>
  );
}
