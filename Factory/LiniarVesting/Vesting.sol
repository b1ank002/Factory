// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "Factory/UtilityContracts/AbstractUtilityContract.sol";
import "./IVesting.sol";

/*
    0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 200
    0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db 300
    0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB 400
    0x617F2E2fD72FD9D5503197092aC168c91465E7f2 100

    root:
    0x8a92c0e48624b04133ae9515ebcc9390940ba18327467d75f16c24a21a2a59cf

    proof for 0xAB...b2, 200:
    ["0x049da3e843e9867f462a9cc50151965d9fe72c32f1d694b5d5586ca9492ffebe", "0x21d9640ea472f42c449e248099933bc3536e6eacf44ba93c6831f0263a0618e0"]
*/

contract Vesting is IVesting, Ownable, AbstractUtilityContract {
    using VestingLib for IVesting.UserInfo;

    constructor() payable Ownable(msg.sender) {}

    IERC20 public token;

    bytes32 public root;

    mapping(bytes32 => IVesting.UserInfo) public beneficiaries;

    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliffDuration;
    uint256 public duration;
    uint256 public minAmount;
    uint256 public cooldown;

    function changeRoot(bytes32 _root) external onlyOwner {
        require(block.timestamp > startTime + duration);

        if (token.balanceOf(address(this)) > 0) this.withdrawUnallocated();

        root = _root;
    }

    function claim(uint256 _amount, bytes32[] calldata _proofs) public {
        uint256 timestamp = block.timestamp;
        if (timestamp < startTime + cliffDuration) {
            revert CliffNotReached(timestamp, startTime + cliffDuration);
        }

        bytes32 leaf = this.makeLeaf(_amount);
        require(MerkleProof.verify(_proofs, root, leaf), VerificationFailed());

        uint256 claimable = claimableAmount(leaf);
        if (claimable < minAmount) revert NothingToClaim();

        IVesting.UserInfo beneficiary = beneficiaries[leaf];
        if (beneficiary.lastClaim > timestamp - cooldown) revert CooldownNotFinished();

        unchecked {
            beneficiaries[leaf].claimed += claimable;
        }
        require(token.transfer(msg.sender, claimable));
        beneficiaries[leaf].lastClaim = timestamp;

        emit Claim(msg.sender, claimable, timestamp);
    }

    function vestedAmount(uint256 _amount) public view returns (uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliffDuration);
        if (passedTime > duration) passedTime = duration;

        return _amount * passedTime / duration;
    }

    function claimableAmount(uint256 _amount, bytes32 leaf) public view returns (uint256) {
        return vestedAmount(_amount) - beneficiaries[leaf].claimed;
    }

    function makeLeaf(uint256 _amount) external view returns (bytes32) {
        bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(msg.sender, _amount))));
        return leaf;
    }

    function initialize(bytes memory _initData) external override notInit returns (bool) {
        (address _deployManager, address _owner, address _token, bytes32 _root) =
            abi.decode(_initData, (address, address, address, bytes32));

        _setDeployManager(_deployManager);

        token = IERC20(_token);
        root = _root;
        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _deployManager, address _owner, address _token, bytes32 _root, uint256 _totalAmount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _owner, _token, _root, _totalAmount);
    }

    function startVesting(IVesting.VestingParams calldata _params) external onlyOwner {
        if (_params.duration == 0) revert IncorrectDuration();
        if (_params.totalAmount == 0) revert AmountCantBeZero();
        uint256 timestamp = block.timestamp;
        if (_params.startTime < timestamp) revert IncorrectStartTime(_params.startTime, timestamp);
        if (_params.cooldown > _params.duration) revert IncorrectCooldown();

        uint256 availableBalance = token.balanceOf(address(this));
        if (availableBalance < _params.totalAmount) revert GoldaNeNaBalike(availableBalance, totalAmount);
        
        totalAmount = _params.totalAmount;
        startTime = _params.startTime;
        cliffDuration = _params.cliffDuration;
        duration = _params.duration;
        minAmount = _params.minAmount;
        cooldown = _params.cooldown;

        emit VestingCreated(totalAmount, startTime, cliffDuration, duration, minAmount, cooldown, timestamp);
    }

    function withdrawUnallocated() external onlyOwner {
        if (block.startTime < startTime + duration) revert NotFinishedYet();

        uint256 avaible = token.balanceOf(address(this));
        if (avaible == 0) revert NothingToWithdraw();
        
        require(token.transfer(owner(), avaible));

        emit TokensWithdraw(avaible, block.timestamp);
    }
}
