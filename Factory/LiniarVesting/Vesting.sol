// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "Factory/UtilityContracts/IUtilityContract.sol";

contract Vesting is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}

    bool private initialized;

    IERC20 public token;

    uint256 public totalAmount;
    uint256 public startTime;
    uint256 public cliffDuration;
    uint256 public claimDuration;
    uint256 public minAmount;
    uint256 public cooldown;

    struct UserInfo {
        uint256 amount;
        uint256 claimed;
        uint256 lastClaim;
    }

    mapping(address => UserInfo) users;

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    error AlreadyInitialized();
    error CliffNotReached();
    error NothingToClaim();
    error TransferFailed();
    error CooldownNotFinished();


    modifier notInit() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function claim() public {
        require(block.timestamp >= startTime + cliffDuration, CliffNotReached());

        uint256 claimable = claimableAmount(msg.sender);
        require(claimable >= minAmount, NothingToClaim());
        require(users[msg.sender].lastClaim < block.timestamp - cooldown);

        users[msg.sender].claimed += claimable;
        require(token.transfer(msg.sender, claimable), TransferFailed());
        users[msg.sender].lastClaim = block.timestamp;

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    function _addUsers(address[] calldata _users, uint256[] calldata _amounts) internal onlyOwner {
        require(_users.length == _amounts.length);
        require(!initialized);

        for (uint256 i = 0; i < _users.length; i++) {
            users[_users[i]] = UserInfo({
                amount: _amounts[i],
                claimed: 0,
                lastClaim: 0
            });
        }
    }  

    function _vestedAmount(address _user) internal view returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliffDuration);

        return users[_user].amount * passedTime / claimDuration;
    }

    function claimableAmount(address _user) public view returns(uint256) {
        if (block.timestamp < startTime + cliffDuration) return 0;

        return _vestedAmount(_user) - users[_user].claimed;
    }

    function setMinClaim(uint256 _newMin) public onlyOwner {
        minAmount = _newMin;
    }

    function setCooldown(uint256 _newCooldown) public onlyOwner {
        cooldown = _newCooldown;
    }

    function initialize(bytes memory _initData) external notInit returns(bool) {
        (address _token, uint256 _amount, address _treasury, address _owner) = abi.decode(_initData, (address, uint256, address, address));

        return initialized = true;
    }

    function getInitData(address _token, uint256 _amount, address _treasury, address _owner) external pure returns(bytes memory) {
        return abi.encode(_token, _amount, _treasury, _owner);
    }
}

