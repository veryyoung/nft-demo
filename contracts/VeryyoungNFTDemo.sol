// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "erc721a/contracts/ERC721A.sol";

contract VeryyoungNFTDemo is ERC721A, ReentrancyGuard, Ownable {
    using ECDSA for bytes32;
    using Address for address;

    enum State {
        Setup,
        Presale,
        Public,
        Finished
    }

    State public state;
    string private baseURI;
    bytes32 private whitelistRoot;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant PRESALE_SUPPLY = 10;
    uint256 public constant PRESALE_MAX_MINT = 2;
    uint256 public constant PUBLIC_MAX_MINT = 5;
    uint256 private PRESALE_PRICE = 1E17; // 0.1 ETH
    uint256 private PUBLIC_PRICE = 3E17; // 0.3 ETH

    mapping(address => uint256) public addressMintedBalance;
    event Minted(address minter, uint256 amount);
    event StateChanged(State state);
    event SignerChanged(address signer);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        bytes32 _whitelistRoot
    ) ERC721A(_name, _symbol) {
        state = State.Setup;
        baseURI = _initBaseURI;
        whitelistRoot = _whitelistRoot;
    }

    function updatePresalePrice(uint256 price) public onlyOwner {
        PRESALE_PRICE = price;
    }

    function updatePublicPrice(uint256 price) public onlyOwner {
        PUBLIC_PRICE = price;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function setStateToSetup() public onlyOwner {
        state = State.Setup;
    }

    function startPresale() public onlyOwner {
        state = State.Presale;
    }

    function setStateToPublic() public onlyOwner {
        state = State.Public;
    }

    function setStateToFinished() public onlyOwner {
        state = State.Finished;
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
    {
        require(state == State.Presale, "Presale is not active.");
        require(!Address.isContract(msg.sender), "Contracts are not allowed.");

        require(
            amount <= PRESALE_MAX_MINT,
            "Amount should not exceed max mint number per transaction."
        );
        require(
            totalSupply() + amount <= PRESALE_SUPPLY,
            "Max supply of tokens exceeded."
        );
        require(
            msg.value >= PRESALE_PRICE * amount,
            "Ether value sent is incorrect."
        );

        bool isUserWhitelisted = isWhitelisted(msg.sender, proof);
        require(isUserWhitelisted, "User is not eligible to the Presale");

        uint256 ownerMintedCount = addressMintedBalance[msg.sender];

        require(
            ownerMintedCount + amount <= PRESALE_MAX_MINT,
            "Max NFT per address exceeded"
        );

        _safeMint(msg.sender, amount);
        addressMintedBalance[msg.sender] = ownerMintedCount + amount;
        emit Minted(msg.sender, amount);
    }

    function mint(uint256 amount) external payable {
        require(state == State.Public, "Sale is not active.");
        require(!Address.isContract(msg.sender), "Contracts are not allowed.");
        require(
            amount <= PUBLIC_MAX_MINT,
            "Amount should not exceed max mint number per transaction."
        );
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Amount should not exceed max supply."
        );
        require(
            msg.value >= PUBLIC_PRICE * amount,
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
