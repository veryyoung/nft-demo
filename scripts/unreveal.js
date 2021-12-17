import fs from "fs";
import path from "path";

const maxSupply = 100;
const desc = "veryyoung nft demo";

const generateNotRevealedMetadata = async () => {
  const filePath = path.join(path.resolve(), "./resources/metadata/not-revealed");
  const indexes = [...Array(maxSupply).keys()];

  for (const id of indexes) {
    const metadata = {
      name: `Veryyoung NFT Demo #${id}`,
      description: desc,
      image: "ipfs://QmQvp2GyrBs5aKkT2UWg4p2cBbF1WDjCYgSBSmzeZzvFvv",
      attributes: []
    };
    fs.writeFileSync(`${filePath}/${id}`, JSON.stringify(metadata));
  }
};

generateNotRevealedMetadata();