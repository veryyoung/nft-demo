// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";

contract VeryyoungNFTSimpleDemo is ERC721A, ReentrancyGuard, Ownable {
    
    string public baseURI;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MAX_MINT = 5;
    uint256 private PRICE = 1E17; // 0.1 ETH
    event Minted(address minter, uint256 amount);
    event BalanceWithdrawed(address recipient, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI) ERC721A(_name, _symbol) {
        baseURI = _initBaseURI;
    }

    function updatePrice(uint256 __price) public onlyOwner {
        PRICE = __price;
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
            totalSupply() + amount <= MAX_SUPPLY,
            "Amount should not exceed max supply"
        );
        require(
            msg.value >= PRICE * amount,
            "Ether value sent is incorrect."
        );
        _safeMint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");
    }

}