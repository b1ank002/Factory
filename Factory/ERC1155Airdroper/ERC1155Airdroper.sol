// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "Factory/UtilityContracts/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdroper is AbstractUtilityContract, Ownable {
    IERC1155 public token;

    bool private initialized;

    address public treasury;

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 30;

    constructor() payable Ownable(msg.sender) {}

    error TokensNotApproved(); // not enough approved tokens
    error IncorrectReceiversLength();
    error IncorrectIdsLength();
    error BatchSizeExceeded();

    function initialize(bytes memory _initData) external override notInit(initialized) returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        _setDeployManager(_deployManager);

        token = IERC1155(_token);
        treasury = _treasury;
        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }

    function airdrop(address[] calldata _receivers, uint256[] calldata _ids, uint256[] calldata _amounts)
        external
        onlyOwner
    {
        require(_ids.length >= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(_receivers.length == _ids.length, IncorrectReceiversLength());
        require(_amounts.length == _ids.length, IncorrectIdsLength());
        require(token.isApprovedForAll(treasury, address(this)), TokensNotApproved());

        address _treasury = treasury;

        for (uint256 i = 0; i < _receivers.length;) {
            token.safeTransferFrom(_treasury, _receivers[i], _ids[i], _amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }
}
