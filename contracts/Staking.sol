// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private AllItems;
    Counters.Counter private Unstakes;
    Counters.Counter private AllClaimed;

    IERC20 public Staking_token;
    IERC20 public Reward_token;

    address public feeTo;
    Position position;

    event UNSTAKE(address Staker, uint256 UnstakedAmount, uint256 StakeId);
    event STAKE(address Staker, uint256 StakedAmount, uint256 StakeId);
    event CLAIMED(address Staker, uint Reward, uint StakeId);

    mapping(uint256 => StakeInformation) public _StakerInfo;
    mapping(address => uint256) public StakerByPosition;
    mapping(address => mapping(uint256 => uint256)) SetTimeForStake;
    mapping(address => uint256[]) AllStakeIdsByStaker;
    mapping(uint256 => uint256) public _RewardOfStakeId;

    constructor(address _StakingToken, address _RewardToken, address _feeTo) {
        Staking_token = IERC20(_StakingToken);
        Reward_token = IERC20(_RewardToken);
        feeTo = _feeTo;
    }

    modifier None(uint256 _position) {
        _None(_position);
        _;
    }

    modifier StakeOwner(uint256 _StakeId) {
        _StakeOwner(_StakeId);
        _;
    }

    modifier Ungoing(uint256 _StakeId) {
        _Ungoing(_StakeId);
        _;
    }

    modifier IsExist(uint256 _StakeId) {
        _IsExist(_StakeId);
        _;
    }

    modifier Fee(uint256 _amount) {
        _FEE(_amount);
        _;
    }

    struct StakeInformation {
        address staker;
        uint256 stakedAmount;
        uint256 reward;
        uint256 startAt;
        uint256 finishAt;
        bool exist;
        bool claimed;
    }

    enum Position {
        None,
        One_month,
        Three_months,
        Six_months,
        One_year
    }

    function CalculateReward(
        uint256 _amount,
        uint256 _position
    ) internal None(_position) returns (uint256 reward) {
        position = Position(_position);
        if (Position(1) == position) {
            reward = SafeMath.div(_amount, 10); // 120APR
        } else if (Position(2) == position) {
            reward = SafeMath.div(_amount, 10) * 4; // 160APR
        } else if (Position(3) == position) {
            reward = _amount; // 200APR
        } else if (Position(4) == position) {
            reward = SafeMath.mul(_amount, 3); // 300APR
        }
    }

    function Choice(
        uint256 _amount,
        uint256 _position
    ) internal None(_position) returns (uint256) {
        require(_amount > 0, "amount");
        position = Position(_position);
        uint256 EndTime;
        if (Position(1) == position) {
            EndTime = block.timestamp + 5 seconds;
        } else if (Position(2) == position) {
            EndTime = block.timestamp + 90 days;
        } else if (Position(3) == position) {
            EndTime = block.timestamp + 182 days + 12 hours;
        } else if (Position(4) == position) {
            EndTime = block.timestamp + 365 days;
        }
        return EndTime;
    }

    function Stake(
        uint256 _StakeAmount,
        uint256 _positionTime
    ) public Fee(_StakeAmount) {
        uint256 Finished = Choice(_StakeAmount, _positionTime);
        uint256 fee = SafeMath.div(_StakeAmount, 10);
        uint256 PureAmount = SafeMath.sub(_StakeAmount, fee);
        uint256 Reward = CalculateReward(PureAmount, _positionTime);
        Staking_token.safeTransferFrom(msg.sender, feeTo, fee);
        Staking_token.safeTransferFrom(msg.sender, address(this), PureAmount);
        AllItems.increment();
        uint current = AllItems.current();
        AllStakeIdsByStaker[msg.sender].push(current);
        _StakerInfo[current].staker = msg.sender;
        _StakerInfo[current].stakedAmount = PureAmount;
        _StakerInfo[current].reward = Reward;
        _StakerInfo[current].finishAt = Finished;
        _StakerInfo[current].exist = true;
        _StakerInfo[current].claimed = false;

        emit STAKE(msg.sender, PureAmount, current);
    }

    function ClaimReward(
        uint StakeId
    ) public Ungoing(StakeId) IsExist(StakeId) StakeOwner(StakeId) {
        uint Reward = _StakerInfo[StakeId].reward;
        _StakerInfo[StakeId].reward = 0;
        Reward_token.transfer(msg.sender, Reward);
        _StakerInfo[StakeId].exist = false;
        _StakerInfo[StakeId].claimed = true;
        AllClaimed.increment();
        emit CLAIMED(msg.sender, Reward, StakeId);
    }

    function Unstake(
        uint256 StakeId
    ) public Ungoing(StakeId) IsExist(StakeId) StakeOwner(StakeId) {
        uint256 StakerStakedAmount = _StakerInfo[StakeId].stakedAmount;
        _StakerInfo[StakeId].stakedAmount = 0;
        Staking_token.transfer(msg.sender, StakerStakedAmount);
        _StakerInfo[StakeId].exist = false;
        Unstakes.increment();
        emit UNSTAKE(msg.sender, StakerStakedAmount, StakeId);
    }

    function StakeIdsByUser() public view returns (uint256[] memory) {
        return AllStakeIdsByStaker[msg.sender];
    }

    function StakerInfo(
        uint256 _StakeId
    ) public view returns (StakeInformation memory) {
        return _StakerInfo[_StakeId];
    }

    function ExistStakes() public view returns (StakeInformation[] memory) {
        uint Allitems = AllItems.current();
        uint unstakes = Unstakes.current();
        uint allcliamed = AllClaimed.current();
        uint exist = Allitems - (unstakes + allcliamed);
        StakeInformation[] memory ExistItems = new StakeInformation[](exist);
        uint j = 0;
        for (uint i = Allitems; i > 0; i--) {
            if (_StakerInfo[i].exist == true) {
                ExistItems[j] = _StakerInfo[i];
                j++;
            }
        }
        return ExistItems;
    }

    function AllClaimedItems() public view returns (StakeInformation[] memory) {
        uint current = AllClaimed.current();
        uint allitems = AllItems.current();
        StakeInformation[] memory Claimed = new StakeInformation[](current);
        uint j = 0;
        for (uint i = allitems; i > 0; i--) {
            if (_StakerInfo[i].claimed) {
                Claimed[j] = _StakerInfo[i];
                j++;
            }
        }
        return Claimed;
    }

    function AllUnstakes() public view returns (StakeInformation[] memory) {
        uint current = Unstakes.current();
        uint allitems = AllItems.current();
        StakeInformation[] memory unstakes = new StakeInformation[](current);
        uint j = 0;
        for (uint i = allitems; i > 0; i--) {
            if (!_StakerInfo[i].claimed && !_StakerInfo[i].exist) {
                unstakes[j] = _StakerInfo[i];
                j++;
            }
        }
        return unstakes;
    }

    function _None(uint _position) private pure {
        require(_position > 0 && _position <= 4, "position");
    }

    function _StakeOwner(uint _StakeId) private view {
        require(_StakerInfo[_StakeId].staker == msg.sender, "not owner");
    }

    function _Ungoing(uint _StakeId) private view {
        require(
            block.timestamp > _StakerInfo[_StakeId].finishAt,
            "Stake still ungoing"
        );
    }

    function _IsExist(uint _StakeId) private view {
        require(_StakerInfo[_StakeId].exist, "not exist");
    }

    function _FEE(uint _amount) private view {
        require(
            _amount > 0 && Staking_token.balanceOf(msg.sender) >= _amount,
            "FEE_ERROR"
        );
    }
}
