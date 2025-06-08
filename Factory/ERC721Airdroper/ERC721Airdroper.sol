// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Airdroper is IUtilityContract, Ownable {
    IERC721 public token;

    address public treasury;

    bool private initialized;

    constructor() payable Ownable(msg.sender) {}

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    error TokensNotApproved(); // not enough approved tokens
    error AlreadyInitialized();
    error IncorrectLength();

    function initialize(bytes memory _initData) external notInit returns (bool) {
        (address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address));

        token = IERC721(_token);
        treasury = _treasury;
        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _token, address _treasury, address _owner) external pure returns (bytes memory) {
        return abi.encode(_token, _treasury, _owner);
    }

    function airdrop(address[] calldata _receivers, uint256[] calldata _ids) external onlyOwner {
        require(_receivers.length == _ids.length, IncorrectLength());
        require(token.isApprovedForAll(treasury, address(this)), TokensNotApproved());

        for (uint256 i = 0; i < _receivers.length; i++) {
            token.safeTransferFrom(treasury, _receivers[i], _ids[i]);
        }
    }
}
