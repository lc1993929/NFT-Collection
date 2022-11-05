// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

abstract contract Brand3TagInterface {

    function makeSlogan(uint256[] memory tokenIds, string[] memory linkStrs)
    public virtual view
    returns (string memory);

}
