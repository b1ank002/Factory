// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "Factory/UtilityContracts/IUtilityContract.sol";

contract BigBoss is IUtilityContract {
    uint256 public number;
    address public bigBoss;

    bool private initialized;

    error AlreadyInitialized(); 

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function initialize(bytes memory _initData) external notInit returns(bool) {
        (uint256 _num, address _bigBoss) = abi.decode(_initData, (uint256, address));

        number = _num;
        bigBoss = _bigBoss;
        return initialized = true;
    }

    function getInitData(uint256 _num, address _bigBoss) external pure returns(bytes memory) {
        return abi.encode(_num, _bigBoss);
    }

    function doSmth() external view returns(uint256, address) {
        return (number, bigBoss);
    }
}