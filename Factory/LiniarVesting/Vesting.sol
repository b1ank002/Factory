// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vesting is Ownable {
    constructor() Ownable(msg.sender) {}

    bool private initialized;

    IERC20 public token;

    bytes32 public root;
    
    struct UserInfo {
        uint256 claimed;
        uint256 lastClaim;
    }

    mapping(address => UserInfo) public beneficiaries;

    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliffDuration;
    uint256 public claimDuration;
    uint256 public minAmount;
    uint256 public cooldown;

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    error AlreadyInitialized();
    error CliffNotReached();
    error NothingToClaim();
    error TransferFailed();
    error CooldownNotFinished();
    error VerificationFailed();

    modifier checkBeneficiary(uint256 _amount, bytes32[] calldata _proofs) {
        bytes32 leaf = keccak256(
            abi.encodePacked(
                keccak256(
                    abi.encodePacked(msg.sender, _amount)
                )
            )
        );
        require(MerkleProof.verify(_proofs, root, leaf), VerificationFailed());
        _;
    }

    function claim(uint256 _amount, bytes32[] calldata _proofs) public {
        require(block.timestamp >= startTime + cliffDuration, CliffNotReached());

        uint256 claimable = claimableAmount(msg.sender, _amount, _proofs);
        require(claimable >= minAmount, NothingToClaim());
        require(beneficiaries[msg.sender].lastClaim < block.timestamp - cooldown, CooldownNotFinished());

        beneficiaries[msg.sender].claimed += claimable;
        require(token.transfer(msg.sender, claimable), TransferFailed());
        beneficiaries[msg.sender].lastClaim = block.timestamp;

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    function _vestedAmount(uint256 _amount) internal view returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliffDuration);

        return _amount * passedTime / claimDuration;
    }

    function claimableAmount(address _beneficiary, uint256 _amount, bytes32[] calldata _proofs) public view checkBeneficiary(_amount, _proofs) returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        return _vestedAmount(_amount) - beneficiaries[_beneficiary].claimed;
    }
}