// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "Factory/IUtilityContract.sol";

contract ERC20Airdroper is IUtilityContract {

    IERC20 public token;
    uint256 public amount;

    bool private initialized;

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    error receiveFailed(address receiver); // receive failed at address receiver
    error notEnough(); // not enough approved tokens
    error AlreadyInitialized();

    function initialize(bytes memory _initData) external notInit returns(bool) {
        (address tokenAddress, uint256 airdropAmount) = abi.decode(_initData, (address, uint256));
        token = IERC20(tokenAddress);
        amount = airdropAmount;

        return initialized = true;
    }

    function getInitData(address _token, uint256 _amount) external pure returns(bytes memory) {
        return abi.encode(_token, _amount);
    }

    function airdrop(address[] calldata _receivers, uint256[] calldata _amounts) external {
        require(_receivers.length == _amounts.length);
        require(token.allowance(msg.sender, address(this)) >= amount, notEnough());

        for(uint256 i = 0; i < _receivers.length; i++) {
            require(token.transferFrom(msg.sender, _receivers[i], _amounts[i]), receiveFailed(_receivers[i]));
        }
    }
}