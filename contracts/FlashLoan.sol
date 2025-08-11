// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReceiver{
    function receiveTokens(address tokenAddress,uint256 amount) external;
}


contract FlashLoan is ReentrancyGuard {
    using SafeMath for uint256;
    Token public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress){
        token = Token(_tokenAddress);
    }

    function depositTokens(uint256 _amount) external nonReentrant{
        require(_amount>0, "Must deposit one token");
        // console.log("Balance before: ", token.balanceOf(address(this)));
        token.transferFrom(msg.sender, address(this), _amount);

        // console.log("Balance after: ", token.balanceOf(address(this)));
        poolBalance = poolBalance.add(_amount);
    }

    function flashLoan(uint256 _borrowAmount) external nonReentrant{
        // console.log("Borrowed amount: ", _borrowAmount);

        require(_borrowAmount>0, "Must borrow at least one token");
    
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore>=_borrowAmount, "Not enough tokens");

        // Ensured by the protocol via the 'depositTokens' function
        assert(poolBalance == balanceBefore);

        // Sends token to receiver
        token.transfer(msg.sender, _borrowAmount);

        // Get Paid Back
        IReceiver(msg.sender).receiveTokens(address(token), _borrowAmount);
        
        // Ensure Loan Paid Back
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter>=balanceBefore, "flashLoan hasn't been paid back");


    }
}