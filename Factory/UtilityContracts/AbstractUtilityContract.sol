// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IUtilityContract} from "./IUtilityContract.sol";
import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/// @title AbstractUtilityContract - abstarct contract for utility contracts
/// @author Blank002
/// @notice Base implementation of functions
abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    /// @notice The address of deploy manager that deployed this contract
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        _setDeployManager(deployManager);
        return true;
    }

    /// @notice Internal function for setting address of deploy manager
    /// @param _deployManager The address of deploy manager
    function _setDeployManager(address _deployManager) internal virtual {
        if (!_validateDeployManager(_deployManager)) {
            revert FailedToSetDeployManager();
        }
        deployManager = _deployManager;
    }

    /// @inheritdoc IUtilityContract
    function getDeployManager() external view virtual override returns (address) {
        return deployManager;
    }

    /// @notice Check is deploy manager is valid 
    /// @param _deployManager The address of deploy manager
    /// @return True if valid
    /// @dev Validate _deployManager isnt address(0) and supports IDeployManager interface
    function _validateDeployManager(address _deployManager) internal view returns (bool) {
        if (_deployManager == address(0)) {
            revert DeployManagerCannotBeZero();
        }

        bytes4 interfaceId = type(IDeployManager).interfaceId;

        if (!IDeployManager(_deployManager).supportsInterface(interfaceId)) {
            revert NotDeployManager();
        }

        return true;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}
