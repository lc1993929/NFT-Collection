// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./SafeMath.sol";

contract Brand3Tag is ERC721Enumerable, Ownable, Pausable {
    using SafeMath for uint256;

    struct Tag {
        uint256 tokenId;
        //tag所在的区域
        uint16 area;
        //tag的内容
        string value;
    }

    //当前总共已被mint的tokenId
    uint256 public tokenIds;

    //tokenId对应的tag
    mapping(uint256 => Tag) public tokenIdToTag;

    //tagValue对应的tag
    mapping(string => Tag) public tagValueToTag;
    //tagValue是否已存在
    mapping(string => bool) public tagValueToExist;

    constructor() ERC721("Brand3Tag", "B3T") {}

    function mint(string memory tagValue, uint16 area) public whenNotPaused {
        //校验tagString是否已经被mint过了
        require(!tagValueToExist[tagValue], "this tag existed");
        //记录tagValue已存在
        tagValueToExist[tagValue] = true;
        //更新tokenId
        tokenIds = tokenIds.add(1);
        //新建tag
        Tag memory tag = Tag(tokenIds, area, tagValue);
        //将tokenId对应的tag保存
        tagValueToTag[tagValue] = tag;
        tokenIdToTag[tokenIds] = tag;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * 从该合约中提取所有的eth到owner
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
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

}
