import Image from 'next/image';

export default function MySoldNFTs({ loadingState, nfts }) {
  if (loadingState === 'loaded' && !nfts.length)
    return <h1 className="py-10 px-20 text-3xl">No assets owned</h1>;
  return (
    <div className="flex justify-center">
      <div className="py-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {nfts.map((nft, i) => (
            <div
              key={nft.tokenId}
              className="border shadow rounded-xl overflow-hidden bg-black"
            >
              <Image
                src={nft.image}
                width="550"
                height="400"
                className="rounded"
                alt=""
              />
              <div className="p-4 bg-black opacity-100">
                <p
                  style={{ height: '32px' }}
                  className="text-2xl text-white text-left font-semibold capitalize"
                >
                  {nft.name}
                </p>
              </div>
              <div className="p-4 bg-black">
                <p className="text-2xl font-bold text-white mb-4">
                  Price - {nft.price} Matic
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
