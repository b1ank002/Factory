// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "Factory/IUtilityContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Airdroper is IUtilityContract, Ownable {

    IERC20 public token;
    uint256 public amount;

    address public treasury;

    bool private initialized;

    constructor() payable Ownable(msg.sender) {}

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    error receiveFailed(address receiver); // receive failed at address receiver
    error notEnough(); // not enough approved tokens
    error AlreadyInitialized();

    function initialize(bytes memory _initData) external notInit returns(bool) {
        (address _token, uint256 _amount, address _treasury, address _owner) = abi.decode(_initData, (address, uint256, address, address));

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _token, uint256 _amount, address _treasury, address _owner) external pure returns(bytes memory) {
        return abi.encode(_token, _amount, _treasury, _owner);
    }

    function airdrop(address[] calldata _receivers, uint256[] calldata _amounts) external onlyOwner {
        require(_receivers.length == _amounts.length);
        require(token.allowance(treasury, address(this)) >= amount, notEnough());

        for(uint256 i = 0; i < _receivers.length; i++) {
            require(token.transferFrom(treasury, _receivers[i], _amounts[i]), receiveFailed(_receivers[i]));
        }
    }
}