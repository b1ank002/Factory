// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IUtilityContract - interface for utility contracts
/// @author Blank002
/// @notice This interface include Errors and Functions of AbstractUtilityContract
interface IUtilityContract is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Revert when contract address equal to zero
    error DeployManagerCannotBeZero();

    /// @dev Revert is contract not deploy manager
    error NotDeployManager();

    /// @dev Revert when feiled setting deploy manager contract
    error FailedToSetDeployManager();


    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice inicialized contract Data (as usuall deployManager, owner, TokenAddress)
    /// @param _initData data in bytes for contract
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice view and return address of deploy manager
    /// @return return address of deploy manager
    function getDeployManager() external view returns (address);
}
