// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "Factory/UtilityContracts/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Airdroper is AbstractUtilityContract, Ownable {
    IERC20 public token;

    uint256 public amount;
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    address public treasury;

    bool private initialized;

    constructor() payable Ownable(msg.sender) {}

    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    error receiveFailed(address receiver); // receive failed at address receiver
    error notEnough(); // not enough approved tokens
    error AlreadyInitialized();
    error IncorrectLength();
    error BatchSizeExceeded();

    function initialize(bytes memory _initData) external override notInit returns (bool) {
        (address _deployManager, address _token, uint256 _amount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        _setDeployManager(_deployManager);

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        _transferOwnership(_owner);

        return initialized = true;
    }

    function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }

    function airdrop(address[] calldata _receivers, uint256[] calldata _amounts) external onlyOwner {
        require(_receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(_receivers.length == _amounts.length, IncorrectLength());
        require(token.allowance(treasury, address(this)) >= amount, notEnough());

        address _treasury = treasury;

        for (uint256 i = 0; i < _receivers.length;) {
            require(token.transferFrom(_treasury, _receivers[i], _amounts[i]), receiveFailed(_receivers[i]));
            unchecked {
                ++i;
            }
        }
    }
}
