// SPDX-License-Identifier: SEE LICENSE IN LICENSE
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
        uint256 claimDuration;
        uint256 minAmount;
        uint256 cooldown;
    }

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

    error CliffNotReached();
    error NothingToClaim();
    error TransferFailed();
    error CooldownNotFinished();
    error VerificationFailed();
    error GoldaNeNaBalike(); // tokens arent on the balance
    error IncorrectStartTime();
    error IncorrectCliff();
    error IncorrectClaimDuration();
    error IncorrectMinAmount();
    error IncorrectCooldown();
    error NotFinishedYet();
    error NothingToWithdraw();

    function claim(uint256 _amount, bytes32[] calldata _proofs) external;
    function startVesting(VestingParams calldata _params) external;
    function _vestedAmount(uint256 _amount) external view returns (uint256);
    function claimableAmount(uint256 _amount, bytes32 leaf) external view returns (uint256);
    function getInitData(address _deployManager, address _owner, address _token, bytes32 _root, uint256 _totalAmount)
        external
        pure
        returns (bytes memory);
    function _makeLeaf(uint256 _amount) external view returns (bytes32);
    function withdrawUnallocated() external;
    function changeRoot(bytes32 _root) external;

}