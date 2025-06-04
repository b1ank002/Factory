// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract asd {
    function returnStamp() public view returns(uint256, uint256) {
        return (block.timestamp + 20, block.timestamp + 100);
    }

    // function wer() public pure returns(bytes32) {
    //     address a = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    //     uint256 n = 200;

    //     bytes32 preLeaf = keccak256(abi.encode(a, n));
    //     bytes32 leaf = keccak256(abi.encode(preLeaf));
    //     return leaf;

    // }
    // 0x037bb4e10b2df41545d73efd5d486e519d2b02abb6c4e5a77ce34effed9aa266
}