// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Blank is ERC20, ERC20Permit {
    constructor(address recipient) payable ERC20("Blank", "blk") ERC20Permit("Blank") {
        _mint(recipient, 100000 * 10 ** decimals());
    }
}
