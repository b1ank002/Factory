// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IVesting.sol";
import "./Vesting.sol";

library VestingLib {

    function vestedAmount() internal view returns (uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;
        uint256 passed = block.timestamp - (startTime + cliffDuration);
        if (passed > duration) passed = duration;
        return (totalAmount * passed) / duration;
    }

    function claimableAmount(IVesting.UserInfo storage u) internal view returns (uint256) {
        uint256 vested = vestedAmount(v);
        if (vested <= u.claimed) return 0;
        return vested - u.claimed;
    }
}