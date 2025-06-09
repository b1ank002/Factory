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

    /// @dev Revert if dont enough founds
    error NotEnoughFunds();

    /// @dev Revert if Initialization of selected contract is failed
    error InitializationFailed();

    /// @dev Revert if tranacion with msg.value to owner failed
    error TransactionFailed();

    /// @dev Check is contract interface supported
    error ContractIsNotUtilityContract();


    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emited when new utility contract added
    /// @param contractAddress address of new contract
    /// @param fee tax (in wei) for this contract deployment
    /// @param isActive status of contract
    /// @param timestamp time where contract was added
    event newContractAdded(address contractAddress, uint256 fee, bool isActive, uint256 timestamp);

    /// @notice Emited when fee(tax) of contarctAddress was changed 
    /// @param contarctAddress address of utility contract
    /// @param oldFee fee of this utility contract
    /// @param newFee new fee of this utility contract
    /// @param timestamp time where fee was changed
    event ContractFeeUpdated(address contarctAddress, uint256 oldFee, uint256 newFee, uint256 timestamp);

    /// @notice Emited when status of contract changed
    /// @param contractAddress address of utility contract
    /// @param isActive new status of contract
    /// @param timestamp time where status was changed
    event ContractStatusUpdated(address contractAddress, bool isActive, uint256 timestamp);

    /// @notice Emited when deployed new utility contract
    /// @param deployer user who deployed
    /// @param contractAddress address of utility contract
    /// @param fee fee(msg.value) which user paid for deployment
    /// @param timestamp time when contract was deployed
    event newDeployment(address deployer, address contractAddress, uint256 fee, uint256 timestamp);


    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploy new utility contract
    /// @param _utilityContract address of utility contract
    /// @param _initData bytes for contract initialization
    /// @return address of new utility contract
    /// @dev Emit newContractAdded event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Added new Utility contract to mapping contractsData
    /// @param _contractAddress address of utility contract
    /// @param _fee fee(im wei) for contract
    /// @param _isActive status for contract(recommended true)
    /// @dev Utility contract need to be deployed and we nned to know address of this contract also it MUST BE utility contract 
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updated fee for utility contract
    /// @param _contaractAddress address of utility contract
    /// @param _newFee new fee(in wei) for contract
    /// @dev function must be onlyOwner
    function updateFee(address _contaractAddress, uint256 _newFee) external;

    /// @notice Update status for utility contract
    /// @param _contractAddress address of utility contract
    /// @param _isActive new status fo utolity contract
    function updateStatus(address _contractAddress, bool _isActive) external;

    /// @notice set status of contract to false
    /// @param _contractAddress address of utility contract
    function deactivateContract(address _contractAddress) external;

    /// @notice set status of contract to true
    /// @param _contractAddress address of utility contract
    /// @dev work same way like deactivateContract()
    function activateContract(address _contractAddress) external;
}
