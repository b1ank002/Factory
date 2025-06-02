// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "Factory/IUtilityContract.sol";

contract DeployManager is Ownable {
    constructor(address init) Ownable(init) {

    }

    mapping(address => address[]) public deployedContracts;
    mapping(address => ContractInfo) public contractsData;

    event newContractAdded(address contractAddress, uint256 fee, bool isActive, uint256 timestamp);
    event ContractFeeUpdated(address contarctAddress, uint256 oldFee, uint256 newFee, uint256 timestamp);
    event ContractStatusUpdated(address contractAddress, bool isActive, uint256 timestamp);
    event newDeployment(address deployer, address contractAddress, uint256 fee, uint256 timestamp);

    struct ContractInfo {
      uint256 fee;
      bool isActive;  
    }

    error ContractNotActive();
    error NotEnoughFunds();
    error InitializationFailed();
    error TransactionFailed();

    function deploy(address _utilityContract, bytes calldata _initData) external payable returns(address) {
        ContractInfo storage info = contractsData[_utilityContract];
        require(info.isActive, ContractNotActive());
        require(msg.value == info.fee, NotEnoughFunds());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        (bool success, ) = payable(owner()).call{value: msg.value}("");
        require(success, TransactionFailed());
        
        deployedContracts[msg.sender].push(clone);

        emit newDeployment(msg.sender, clone, info.fee, block.timestamp);

        return clone;
    }

    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external onlyOwner {
        contractsData[_contractAddress] = ContractInfo ({
            fee: _fee,
            isActive: _isActive
        });

        emit newContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    function updateFee(address _contaractAddress, uint256 _newFee) external onlyOwner {
        uint256 _oldFee = contractsData[_contaractAddress].fee;
        contractsData[_contaractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contaractAddress, _oldFee, _newFee, block.timestamp);
    }

    function deactivateContract(address _contractAddress) external onlyOwner {
        contractsData[_contractAddress].isActive = false;

        emit ContractStatusUpdated(_contractAddress, false, block.timestamp);
    }

    function activateContract(address _contractAddress) external onlyOwner {
        contractsData[_contractAddress].isActive = true;

        emit ContractStatusUpdated(_contractAddress, true, block.timestamp);
    }
}