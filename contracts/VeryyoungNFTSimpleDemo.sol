// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract VeryyoungNFTDemo is
    ERC721Enumerable,
    ERC721URIStorage,
    ReentrancyGuard,
    Ownable
{
    using ECDSA for bytes32;
    using Address for address;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    string public baseURI;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MAX_MINT = 5;
    uint256 private PRICE = 1E17; // 0.1 ETH
    event Minted(address minter, uint256 amount);
    event BalanceWithdrawed(address recipient, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
    }

    function updatePrice(uint256 __price) public onlyOwner {
        PRICE = __price;
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return
            string(abi.encodePacked(_baseURI(), Strings.toString(tokenId)));
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function mint(uint256 amount) external payable nonReentrant {
        require(
            !Address.isContract(msg.sender),
            "Contracts are not allowed."
        );
        require(
            amount <= MAX_MINT,
            "Amount should not exceed max mint number per transaction."
        );
        require(
            _tokenIds.current() + amount <= MAX_SUPPLY,
            "Amount should not exceed max supply"
        );
        require(
            msg.value >= PRICE * amount,
            "Ether value sent is incorrect."
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            _tokenIds.increment();
        }
        emit Minted(msg.sender, amount);
    }

    function withdraw(address payable _to) public onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, bytes memory data) = _to.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}