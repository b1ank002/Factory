// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";

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

contract Vesting is Ownable, IUtilityContract {
    constructor() Ownable(msg.sender) {}

    bool private initialized;

    IERC20 public token;

    bytes32 public root;

    struct UserInfo {
        uint256 claimed;
        uint256 lastClaim;
    }

    mapping(bytes32 => UserInfo) public beneficiaries;

    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliffDuration;
    uint256 public claimDuration;
    uint256 public minAmount;
    uint256 public cooldown;

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);
    event VestingCreated(
        uint256 startTime,
        uint256 cliffDuration,
        uint256 claimDuration,
        uint256 minAmount,
        uint256 cooldown,
        uint256 timestamp
    );
    event TokensWithdraw(uint256 amount, uint256 timestamp);

    error AlreadyInitialized();
    error CliffNotReached();
    error NothingToClaim();
    error TransferFailed();
    error CooldownNotFinished();
    error VerificationFailed();
    error GoldaNeNaBalike(); // tokens dont on balance
    error IncorrectStartTime();
    error IncorrectCliff();
    error IncorrectClaimDuration();
    error IncorrectMinAmount();
    error IncorrectCooldown();
    error NotFinishedYet();
    error NothingToWithdraw();

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function claim(uint256 _amount, bytes32[] calldata _proofs) public {
        require(block.timestamp >= startTime + cliffDuration, CliffNotReached());

        bytes32 leaf = _makeLeaf(_amount);
        require(MerkleProof.verify(_proofs, root, leaf), VerificationFailed());

        uint256 claimable = claimableAmount(_amount, leaf);
        require(claimable >= minAmount, NothingToClaim());
        require(
            beneficiaries[leaf].lastClaim == 0 || beneficiaries[leaf].lastClaim < block.timestamp - cooldown,
            CooldownNotFinished()
        );

        beneficiaries[leaf].claimed += claimable;
        require(token.transfer(msg.sender, claimable), TransferFailed());
        beneficiaries[leaf].lastClaim = block.timestamp;

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    function _vestedAmount(uint256 _amount) internal view returns (uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliffDuration);
        if (passedTime > claimDuration) passedTime = claimDuration;

        return _amount * passedTime / claimDuration;
    }

    function claimableAmount(uint256 _amount, bytes32 leaf) public view returns (uint256) {
        return _vestedAmount(_amount) - beneficiaries[leaf].claimed;
    }

    function _makeLeaf(uint256 _amount) internal view returns (bytes32) {
        bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(msg.sender, _amount))));
        return leaf;
    }

    function initialize(bytes memory _initData) external notInit returns (bool) {
        (address _owner, address _token, bytes32 _root, uint256 _totalAmount) =
            abi.decode(_initData, (address, address, bytes32, uint256));

        token = IERC20(_token);
        root = _root;
        totalAmount = _totalAmount;
        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _owner, address _token, bytes32 _root, uint256 _totalAmount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_owner, _token, _root, _totalAmount);
    }

    function startVesting(
        uint256 _startTime,
        uint256 _cliffDuration,
        uint256 _claimDuration,
        uint256 _minAmount,
        uint256 _cooldown
    ) external onlyOwner {
        require(token.balanceOf(address(this)) >= totalAmount, GoldaNeNaBalike());
        require(_startTime >= block.timestamp, IncorrectStartTime());
        require(_cliffDuration < _claimDuration, IncorrectCliff());
        require(_claimDuration > 0, IncorrectClaimDuration());
        require(_minAmount > 0, IncorrectMinAmount());
        require(_cooldown < _claimDuration, IncorrectCooldown());

        startTime = _startTime;
        cliffDuration = _cliffDuration;
        claimDuration = _claimDuration;
        minAmount = _minAmount;
        cooldown = _cooldown;

        emit VestingCreated(_startTime, _cliffDuration, _claimDuration, _minAmount, _cooldown, block.timestamp);
    }

    function withdrawUnallocated() external onlyOwner {
        require(block.timestamp > startTime + claimDuration, NotFinishedYet());

        uint256 avaible = token.balanceOf(address(this));
        require(avaible > 0, NothingToWithdraw());
        require(token.transfer(owner(), avaible), TransferFailed());

        emit TokensWithdraw(avaible, block.timestamp);
    }
}
