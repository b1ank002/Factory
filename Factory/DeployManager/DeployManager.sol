// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";
import "./IDeployManager.sol";

/// @title Factory with different utility contracts
/// @author Blank002
/// @notice This contract is main logic of deployment and appointment system of Factory
contract DeployManager is IDeployManager, Ownable, ERC165 {
    constructor(address init) payable Ownable(init) {}

    /// @notice user address => users utility contracts
    mapping(address => address[]) public deployedContracts;

    /// @notice address of utility contract => ContarctInfo (fee and status of utility contract also registered time)
    mapping(address => ContractInfo) public contractsData;

    /// @dev Store registered contract information
    struct ContractInfo {
        uint256 fee; /// @notice Deployment fee(in wei)
        bool isActive; /// @notice Show active status
        uint256 registeredAt; /// @notice Registration time
    }

    /// @inheritdoc IDeployManager
    function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address) {
        ContractInfo storage info = contractsData[_utilityContract];
        require(info.isActive, ContractNotActive());
        require(msg.value == info.fee, NotEnoughFunds());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        (bool success,) = payable(owner()).call{value: msg.value}("");
        require(success, TransactionFailed());

        deployedContracts[msg.sender].push(clone);

        emit newDeployment(msg.sender, clone, info.fee, block.timestamp);

        return clone;
    }

    /// @inheritdoc IDeployManager
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        require(
            IUtilityContract(_contractAddress).supportsInterface(type(IUtilityContract).interfaceId),
            ContractIsNotUtilityContract()
        );
        require(contractsData[_contractAddress].registeredAt == 0, AlreadyRegistered());

        contractsData[_contractAddress] = ContractInfo({fee: _fee, isActive: _isActive, registeredAt: block.timestamp});

        emit newContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateStatus(address _contractAddress, bool _isActive) external override onlyOwner {
        contractsData[_contractAddress].isActive = _isActive;

        emit ContractStatusUpdated(_contractAddress, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function deactivateContract(address _contractAddress) external override onlyOwner {
        contractsData[_contractAddress].isActive = false;

        emit ContractStatusUpdated(_contractAddress, false, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function activateContract(address _contractAddress) external override onlyOwner {
        contractsData[_contractAddress].isActive = true;

        emit ContractStatusUpdated(_contractAddress, true, block.timestamp);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}
