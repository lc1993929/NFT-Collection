// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Brand3TagInterface.sol";

contract Brand3Slogan is ERC721, ERC721Enumerable, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    //tokenId对应的tag
    mapping(uint256 => string) public tokenIdToSlogan;
    //slogan是否已存在
    mapping(string => bool) public sloganToExist;

    //记录所有已被授权可以mint的地址
    mapping(address => bool) public addressToMint;

    modifier onlyMinter() {
        require(addressToMint[_msgSender()], "caller is not the minter");
        _;
    }

    //tag合约的地址
    address public Brand3TagAddress;


    constructor(address B3TagAddress) ERC721("Brand3Slogan", "B3S") {
        addressToMint[msg.sender] = true;
        Brand3TagAddress = B3TagAddress;
    }

    function updateBrand3TagAddress(address B3TagAddress) public onlyOwner {
        Brand3TagAddress = B3TagAddress;
    }


    function mint(uint256[] memory tokenIds, string[] memory linkStrs) public onlyMinter whenNotPaused {
        //新建slogan
        Brand3TagInterface brand3TagInstance = Brand3TagInterface(Brand3TagAddress);
        string memory slogan = brand3TagInstance.makeSlogan(tokenIds,linkStrs);
        //校验slogan是否已经被mint过了
        require(!sloganToExist[slogan], "this slogan existed");
        //记录tagValue已存在
        sloganToExist[slogan] = true;
        //更新tokenId
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        //将tokenId对应的slogan保存
        tokenIdToSlogan[tokenId] = slogan;
        _safeMint(msg.sender, tokenId);
    }

    function addMintAddress(address addr) public onlyOwner whenNotPaused {
        addressToMint[addr] = true;
    }

    function delMintAddress(address addr) public onlyOwner whenNotPaused {
        addressToMint[addr] = false;
    }


    /**
     * 从该合约中提取所有的eth到owner
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent,) = _owner.call{value : amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
