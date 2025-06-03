// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";

contract Vesting is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}

    bool private initialized;

    IERC20 public token;

    address public beneficiary;

    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliffDuration;
    uint256 public claimDuratoin;
    uint256 public claimed;

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    error AlreadyInitialized();
    error NotBeneficiary();
    error CliffNotReached();
    error NothingToClaim();
    error TransferFailed();

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function claim() public {
        require(msg.sender == beneficiary, NotBeneficiary());
        require(block.timestamp >= startTime + cliffDuration, CliffNotReached());

        uint256 claimable = claimableAmount();
        require(claimable > 0, NothingToClaim());

        claimed += claimable;
        require(token.transfer(beneficiary, claimable), TransferFailed());

        emit Claim(beneficiary, claimable, block.timestamp);
    }

    function _vestedAmount() internal view returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliffDuration);

        return totalAmount * passedTime / claimDuratoin;
    }

    function claimableAmount() public view returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        return _vestedAmount() - claimed;
    }

    function initialize(bytes memory _initData) external notInit returns(bool) {
        (address _token, uint256 _amount, address _treasury, address _owner) = abi.decode(_initData, (address, uint256, address, address));

        return initialized = true;
    }

    function getInitData(address _token, uint256 _amount, address _treasury, address _owner) external pure returns(bytes memory) {
        return abi.encode(_token, _amount, _treasury, _owner);
    }
}

