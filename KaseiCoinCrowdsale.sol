pragma solidity ^0.5.0;

import "./KaseiCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// KaseiCoin Address: 0x78CC7f70c8f41322095b3DeD61E6b43081a01978
//                          0x25d20BbE3F4935BC783C66D17BCDEe933C70b511
//                          
// Have the KaseiCoinCrowdsale contract inherit the following OpenZeppelin: 0xCb81B8A94ae0a30D494bEffee3cc7902d3ffBb3e
// * Crowdsale
// * MintedCrowdsale
// Coin name: KaseiCoin
// Coin Symbol: KAI

contract KaseiCoinCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale { // UPDATE THE CONTRACT SIGNATURE TO ADD INHERITANCE
    bool public isFundSuccess = false;
    bool public isFundEnable = true;
    bool public fundsWithdraw = false;
    uint256 public dateline;
    uint256 public targetFunds;

    mapping(address => uint256) public funders;

    event Funded(address _funder, uint256 _amount);
    event FunderWithdraw(address _funder, uint256 _amount);
    event OwnerWithdrawFunds(address _owner, uint256 _amount);

    // Provide parameters for all of the features of your crowdsale, such as the `rate`, `wallet` for fundraising, and `token`.
    constructor(
        uint _rate,
        address payable _wallet,
        KaseiCoin _coin,
        uint goal,
        uint open,
        uint closed
    ) public Crowdsale(_rate, _wallet, _coin) 
                CappedCrowdsale(goal) 
                TimedCrowdsale(open, closed) 
                RefundableCrowdsale(goal) { 
        // constructor can stay empty
    }

    function Fund() public payable {
        require(isFundEnable, "Funding is not enable.");

        funders[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    function withdrawOwnerFunds() public {
        require(msg.sender == wallet(), "Only owner can withdraw funds.");
        require(isFundSuccess, "Funding was not successful.");

        uint256 amountToWithdraw = address(this).balance;
        // (bool success, ) = wallet().call{value: amountToWithdraw}("");
        // require(success, "Owner Withdraw Fail.");

        // Use the send function to send funds
        bool success = wallet().send(amountToWithdraw);
        require(success, "Transfer failed");
        fundsWithdraw = true;
        emit OwnerWithdrawFunds(msg.sender, amountToWithdraw);
    }
}

contract KaseiCoinCrowdsaleDeployer {
    address public kasei_token_address;
    address public kasei_crowdsale_address;

    // Add the constructor.
    constructor(
        string memory _name,
        string memory _symbol,
        address payable _wallet
    )
        public
    {
        KaseiCoin coin = new KaseiCoin(_name, _symbol, 0);
        kasei_token_address = address(coin);

        KaseiCoinCrowdsale kaseicoin_crowdsale = new KaseiCoinCrowdsale(1, _wallet, coin, 10, now, now + 5 minutes );
        kasei_crowdsale_address = address(kaseicoin_crowdsale);

        coin.addMinter(kasei_crowdsale_address);
        coin.renounceMinter();
    }
}

/*
contract KaseiCoinCrowdsaleDeployer {
    // Create an `address public` variable called `kasei_token_address`.
    // YOUR CODE HERE!
    // Create an `address public` variable called `kasei_crowdsale_address`.
    // YOUR CODE HERE!

    // Add the constructor.
    constructor(
       // YOUR CODE HERE!
    ) public {
        // Create a new instance of the KaseiCoin contract.
        // YOUR CODE HERE!
        
        // Assign the token contract’s address to the `kasei_token_address` variable.
        // YOUR CODE HERE!

        // Create a new instance of the `KaseiCoinCrowdsale` contract
        // YOUR CODE HERE!
            
        // Aassign the `KaseiCoinCrowdsale` contract’s address to the `kasei_crowdsale_address` variable.
        // YOUR CODE HERE!

        // Set the `KaseiCoinCrowdsale` contract as a minter
        // YOUR CODE HERE!
        
        // Have the `KaseiCoinCrowdsaleDeployer` renounce its minter role.
        // YOUR CODE HERE!
    }
}
*/

