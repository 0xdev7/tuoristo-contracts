// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Token {
    function transferFrom(address from, address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract TokenPresale is Ownable {
    using SafeMath for uint256;

    Token public token;
    
    address public mainWallet;
    
    uint256 public totalDepositedBNBBalance;
    uint256 public rewardTokenCount;

    mapping(address => uint256) public deposits;

    constructor(Token _token) {
        token = _token;
        
        mainWallet = address(0);
        
        rewardTokenCount = 2000000000000000;
    }

    receive() payable external {
        deposit();
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }

    function deposit() public payable {
        uint256 tokenAmount = msg.value.mul(1e8).div(rewardTokenCount);
        
        token.transferFrom(mainWallet, msg.sender, tokenAmount);
        
        totalDepositedBNBBalance = totalDepositedBNBBalance.add(msg.value);
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        emit Deposited(msg.sender, msg.value);
    }
    
    function releaseFunds() external onlyOwner {
        payable(mainWallet).transfer(address(this).balance);
        totalDepositedBNBBalance = totalDepositedBNBBalance.sub(address(this).balance);
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).transfer(this.owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setWithdrawAddress(address payable _address) external onlyOwner {
        mainWallet = _address;
    }
    
    function getWithdrawAddress() public view returns (address) {
        return mainWallet;
    }
    
    function setRewardTokenCount(uint256 _count) external onlyOwner {
        rewardTokenCount = _count;
    }
    
    function getRewardTokenCount() public view returns (uint256) {
        return rewardTokenCount;
    }

    function getDepositAmount() public view returns (uint256) {
        return totalDepositedBNBBalance;
    }

    event Deposited(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
}