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

    /// @dev Revert when deploy manager address equal to zero
    error DeployManagerCannotBeZero();

    /// @dev Revert when contract isnt deploy manager
    error NotDeployManager();

    /// @dev Revert when setting deploy manager contract failed
    error FailedToSetDeployManager();

    error AlreadyInitialized();

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Initialized contract Data (as usual deployManager, owner, TokenAddress)
    /// @param _initData data in bytes for clone of utility contract
    /// @return True if the initialization was successful
    /// @dev This function should be called by deploy manager contract after deploying a clone of utility contract 
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice View and return address of deploy manager contract
    /// @return return The address of deploy manager contract
    function getDeployManager() external view returns (address);
}
