// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IVesting {
    struct UserInfo {
        uint256 claimed;
        uint256 lastClaim;
    }

    struct VestingParams {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 duration;
        uint256 minAmount;
        uint256 cooldown;
    }

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);
    event VestingCreated(
        uint256 totalAmount,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 duration,
        uint256 minAmount,
        uint256 cooldown,
        uint256 timestamp
    );
    event TokensWithdraw(uint256 amount, uint256 timestamp);

    error CliffNotReached(uint256 timestamp, uint256 finishCliffTime);
    error NothingToClaim();
    error CooldownNotFinished();
    error VerificationFailed();
    error GoldaNeNaBalike(uint256 availableBalance, uint256 totalAmount); // tokens arent on the balance
    error IncorrectStartTime(uint256 startTime, uint256 timestamp);
    error IncorrectDuration();
    error IncorrectCooldown();
    error NotFinishedYet();
    error NothingToWithdraw();
    error AmountCantBeZero();

    function claim(uint256 _amount, bytes32[] calldata _proofs) external;
    function startVesting(VestingParams calldata _params) external;
    function vestedAmount(uint256 _amount) external view returns (uint256);
    function claimableAmount(uint256 _amount, bytes32 leaf) external view returns (uint256);
    function getInitData(address _deployManager, address _owner, address _token, bytes32 _root, uint256 _totalAmount)
        external
        pure
        returns (bytes memory);
    function makeLeaf(uint256 _amount) external view returns (bytes32);
    function withdrawUnallocated() external;
    function changeRoot(bytes32 _root) external;

}