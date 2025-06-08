// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";

contract CroundFunding is Ownable, IUtilityContract {
    constructor() Ownable(msg.sender) {}

    address public vesting;

    uint256 public goal;
    uint256 public duration; // in sec btw
    uint256 public received;

    bool public isFinished;
    bool public initialized;

    mapping(address => uint256) public investors;

    error CroudAlreadyFinished();
    error OutOfGoal();
    error NotEnoughFoundsOrZero();
    error TransferFailed();
    error WithdrawFailed();
    error AlreadyInitialized();
    error CroudNotFinished();
    error AlreadyExist();
    error VestingNotSet();
    error WithdrawWasCalled();

    event Contributed(address investor, uint256 value, uint256 timestamp);
    event VestlingCreated(address vestling, uint256 timestamp);
    event Refunded(address investor, uint256 value, uint256 timestamp);

    modifier finishControl() {
        require(!isFinished, CroudAlreadyFinished());
        _;
    }

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function contribute() external payable finishControl {
        require(vesting == address(0), AlreadyExist());
        require(msg.value + received <= goal && msg.value > 0, OutOfGoal());

        investors[msg.sender] += msg.value;
        received += msg.value;
        emit Contributed(msg.sender, msg.value, block.timestamp);

        if (received == goal) _createVesting();
    }

    function _createVesting() private {
        isFinished = true;
        vesting = address(new VestingWallet(owner(), uint64(block.timestamp), uint64(duration)));

        emit VestlingCreated(vesting, block.timestamp);
    }

    function refund(uint256 _value) external finishControl {
        require(investors[msg.sender] >= _value && _value > 0, NotEnoughFoundsOrZero());

        investors[msg.sender] -= _value;
        received -= _value;

        require(_transferProcces(_value), TransferFailed());

        emit Refunded(msg.sender, _value, block.timestamp);
    }

    function _transferProcces(uint256 _value) private returns (bool) {
        (bool success,) = payable(msg.sender).call{value: _value}("");
        return success;
    }

    function withdraw() external onlyOwner {
        require(isFinished, CroudNotFinished());
        require(address(this).balance > 0, WithdrawWasCalled());
        require(vesting != address(0), VestingNotSet());

        (bool succes,) = payable(vesting).call{value: address(this).balance}("");
        require(succes, WithdrawFailed());
    }

    function initialize(bytes memory _initData) external notInit returns (bool) {
        (address fundriser, uint256 _goal, uint256 _duration) = abi.decode(_initData, (address, uint256, uint256));

        _transferOwnership(fundriser);
        goal = _goal;
        duration = _duration;

        return initialized = true;
    }

    function getInitData(address fundriser, uint256 _goal, uint256 _duration) external pure returns (bytes memory) {
        return abi.encode(fundriser, _goal, _duration);
    }
}
