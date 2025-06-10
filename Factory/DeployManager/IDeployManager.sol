// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title Factory with different utility contracts
/// @author Blank002 
/// @notice This interface include Errors, Events and Functions
interface IDeployManager is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Check is contract active
    error ContractNotActive();

    /// @dev Revert if dont enough founds to deploy
    error NotEnoughFunds();

    /// @dev Revert if Address contract and/or _initData with errors
    error InitializationFailed();

    /// @dev Revert if founds (msg.value) when transfered to owner() failed
    error TransactionFailed();

    /// @dev Check is contract supported interfaces of utility contract and ERC-165
    error ContractIsNotUtilityContract();

    /// @dev Revert if utility contract alrady registered
    error AlreadyRegistered();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emited when new utility contract added
    /// @param contractAddress The address of new utility contract
    /// @param fee Fee(in wei) for clone of this contract deployment
    /// @param isActive Status of contract (active - true, deactive - false)
    /// @param timestamp Timestamp when contract was added
    event newContractAdded(address contractAddress, uint256 fee, bool isActive, uint256 timestamp);

    /// @notice Emited when fee of utility contract was changed 
    /// @param contarctAddress Address of utility contract
    /// @param oldFee Fee of this utility contract before changes
    /// @param newFee Fee of this utility contract after changes
    /// @param timestamp Timestamp when fee was changed
    event ContractFeeUpdated(address contarctAddress, uint256 oldFee, uint256 newFee, uint256 timestamp);

    /// @notice Emited when utility contract status was changed
    /// @param contractAddress The address of utility contract
    /// @param isActive New status for utility contract
    /// @param timestamp Timestamp when status was changed
    event ContractStatusUpdated(address contractAddress, bool isActive, uint256 timestamp);

    /// @notice Emited when new utility contarct was deployed
    /// @param deployer The address which deployed contract
    /// @param contractAddress The address of utility contract
    /// @param fee Fee(in wei) paid for clone of utility contract deployment
    /// @param timestamp Timestamp when contract was deployed
    event newDeployment(address deployer, address contractAddress, uint256 fee, uint256 timestamp);

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploy new clone of utility contract
    /// @param _utilityContract The address of utility contract
    /// @param _initData Initialize data for clone of utility contract
    /// @return address The address of the new clon of utility contract
    /// @dev Emit newContractAdded event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Added new utility contract to mapping contractsData
    /// @param _contractAddress The address of utility contract
    /// @param _fee Fee(in wei) for contract
    /// @param _isActive Status for contract(recommended true)
    /// @dev Utility contract must be deployed and need to have address of this contract also it MUST BE utility contract 
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Update fee for utility contract
    /// @param _contaractAddress The address of utility contract
    /// @param _newFee New fee(in wei) for utility contract
    /// @dev Function must be onlyOwner
    function updateFee(address _contaractAddress, uint256 _newFee) external;

    /// @notice Update status for utility contract
    /// @param _contractAddress The address of utility contract
    /// @param _isActive New status of utility contract
    /// @dev Must be onlyOwner
    function updateStatus(address _contractAddress, bool _isActive) external;

    /// @notice Set status of utility contract to false
    /// @param _contractAddress The address of utility contract
    /// @dev Work same way like updateStatus() but with out status input
    function deactivateContract(address _contractAddress) external;

    /// @notice Set status of utility contract to true
    /// @param _contractAddress The address of utility contract
    /// @dev Work same way like deactivateContract()
    function activateContract(address _contractAddress) external;
}
