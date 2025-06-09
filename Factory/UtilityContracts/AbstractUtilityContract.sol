// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IUtilityContract} from "./IUtilityContract.sol";
import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/// @title AbstractUtilityContract - abstarct contract for utility contracts
/// @author Blank002
/// @notice Base implementation of functions
abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        _setDeployManager(deployManager);
        return true;
    }

    /// @notice internal func for setting address of deploy manager
    /// @param _deployManager address of deploy manager
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

    /// @notice check is deploy manager valid
    /// @param _deployManager address of deploy manager
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

    /// @notice function to check is contract siganture equal signature of deploy manager contract
    /// @param interfaceId signature of contract
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}
