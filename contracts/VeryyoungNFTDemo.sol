// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

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

    enum State {
        Setup,
        Presale,
        Public, 
        Finished
    }
    
    State private _state;
    string private _tokenUriBase;
    bytes32 private whitelistRoot;


    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant PRESALE_SUPPLY = 10;
    uint256 public constant PRESALE_MAX_MINT = 2;
    uint256 public constant PUBLIC_MAX_MINT = 5;
    uint256 private PRESALE_PRICE = 1E17; // 0.1 ETH
    uint256 private PUBLIC_PRICE = 3E17; // 0.3 ETH

    mapping(address => uint256) public addressMintedBalance;
    event Minted(address minter, uint256 amount);
    event StateChanged(State _state);
    event SignerChanged(address signer);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        bytes32 _whitelistRoot) ERC721(_name, _symbol) {
        _state = State.Setup;
        setBaseURI(_initBaseURI);
        whitelistRoot = _whitelistRoot;
    }

    function updatePresalePrice(uint256 __price) public onlyOwner {
        PRESALE_PRICE = __price;
    }

    function updatePublicPrice(uint256 __price) public onlyOwner {
        PUBLIC_PRICE = __price;
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

    function setStateToSetup() public onlyOwner {
        _state = State.Setup;
    }
    
    function startPresale() public onlyOwner {
        _state = State.Presale;
    }

    function setStateToPublic() public onlyOwner {
        _state = State.Public;
    }
    
    function setStateToFinished() public onlyOwner {
        _state = State.Finished;
    }

    function setWhitelistRoot(bytes32 _whitelistRoot) public onlyOwner {
        whitelistRoot = _whitelistRoot;
    }

    function isWhitelisted(address user, bytes32[] memory proof)
        public
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                proof,
                whitelistRoot,
                keccak256(abi.encodePacked(user))
            );
    }

    function presaleMint(uint256 amount, bytes32[] memory proof)
        external
        payable
        nonReentrant
    {
        require(_state == State.Presale, "Presale is not active.");
        require(
            !Address.isContract(msg.sender),
            "Contracts are not allowed."
        );

        require(
            amount <= MAX_MINT,
            "Amount should not exceed max mint number per transaction."
        );
        require(
            _tokenIds.current() + 1 <= PRESALE_SUPPLY,
            "Max supply of tokens exceeded."
        );
        require(msg.value >= PRESALE_PRICE, "Ether value sent is incorrect.");

        bool isUserWhitelisted = isWhitelisted(msg.sender, proof);
        require(
            isUserWhitelisted,
            "User is not eligible to the Presale"
        );

        uint256 ownerMintedCount = addressMintedBalance[msg.sender];

        require(
            ownerMintedCount + amount <= maxWhitelistNfts,
            "Max NFT per address exceeded"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            _tokenIds.increment();
            addressMintedBalance[msg.sender]++;
        }
        emit Minted(msg.sender, amount);
    }

    function mint(
        uint256 amount
    ) external payable nonReentrant {
        require(_state == State.Public, "Sale is not active.");
        require(
            !Address.isContract(msg.sender),
            "Contracts are not allowed."
        );
        require(
            amount <= PUBLIC_MAX_MINT,
            "Amount should not exceed max mint number per transaction."
        );
        require(
            _tokenIds.current() + amount <= MAX_SUPPLY,
            "Amount should not exceed max supply."
        );
        require(
            msg.value >= PUBLIC_PRICE * amount,
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