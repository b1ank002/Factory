// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract ourVestingWallet is VestingWallet {
    constructor(address _beneficiary, uint64 _duration) VestingWallet(_beneficiary, uint64(block.timestamp), _duration) payable {}
}