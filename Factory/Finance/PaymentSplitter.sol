// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/*
    ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
    [55, 45]
*/

contract RevenueSplitter is PaymentSplitter {
    constructor(address[] memory payees_, uint256[] memory shares_) PaymentSplitter(payees_, shares_) payable {}

    function receive() external payable { }

    function release(address payable _to) public override {
        require(msg.sender == _to, "u cant transfer money");
        super.release(_to);
    }
}

