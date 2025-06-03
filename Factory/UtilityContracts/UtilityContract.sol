// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "Factory/UtilityContracts/IUtilityContract.sol";

contract UtilityContract is IUtilityContract {
    uint256 public number;
    address public owner;

    function initialize(bytes memory) external returns(bool) {

    }
}