//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

import "./PriceFeedConsumerV3.sol";

contract FundUkraine is ERC1155 {
    using SafeMath for uint;

    // Ukraine Donation Receive Address
    // Mainnet 0x165CD37b4C644C2921454429E7F9358d18A45e14
    address payable public beneficiary;

    address public  deployer;

    address public daiAddress;

    // Military
    uint8 public constant JAVELIN = 0; // Shoulder Mount Anti Tank
    uint8 public constant HIMARS = 1; // High Mobility Artillery System
    uint8 public constant STINGER = 2; // Shoulder Mount Anti Air
    uint8 public constant NASAMS = 3; // Surface to air missile defense system
    uint8 public constant NVG = 4; // Night vision goggles
    uint8 public constant AMMO = 5; // Ammunition

    // Humanitarian
    uint8 public constant FOOD = 6;
    uint8 public constant MEDICKIT = 7;
    uint8 public constant WATER = 8;
    uint8 public constant PSYCH = 9; // psychological support

    // Prices
    mapping(uint8 => uint256) public itemPricesUSD;

    // DAI Contributors => amount
    mapping(address => uint256) public contributors;

    event Withdraw(address to, uint amount);

    constructor(address _beneficiary, address _daiAddress) ERC1155("https://ipfs.io/ipfs/{id}.json") {
        deployer = msg.sender;
        beneficiary = payable(_beneficiary);
        daiAddress = _daiAddress;

        itemPricesUSD[0] = 175_203; // Javelin
        itemPricesUSD[1] = 5_100_000; // HIMARS
        itemPricesUSD[2] = 38_000; // Stinger (Missile Only)_
        itemPricesUSD[3] = 50_000_000; // NASAMS
        itemPricesUSD[4] = 41_000; // NVGs
        itemPricesUSD[5] = 38_000; // Ammo
    }

    function mintOnDonation(uint8 itemId, uint amount, address who) internal {
        _mint(who, itemId, amount, "");
    }

    function donateWithDai(uint8 itemId, uint256 usdAmount) public {
        console.log("usdamount => ", usdAmount);
        require(IERC20(daiAddress).allowance(msg.sender, address(this)) >= usdAmount, "User needs to give spend approval to FundUkraine contract.");

        uint256 amountToMint = itemPricesUSD[itemId].div(usdAmount);
        
        // transfer directly to Beneficiary 
        IERC20(daiAddress).transferFrom(msg.sender, address(beneficiary), usdAmount);

        if(contributors[msg.sender] != 0) {
            contributors[msg.sender] += usdAmount;
        } else {
            contributors[msg.sender] = usdAmount;
        }

        mintOnDonation(itemId, amountToMint, msg.sender);
    }

    function donateWithEth(uint8 itemId) public payable {
        require(msg.value > 0, "you need to donate more than zero.");

        console.log("msg.value => ", msg.value);

        // uint ethPrice = priceFeed.latestAnswer();
        uint256 ethPrice = 3000e7;
        uint256 amountInUSD = msg.value.div(ethPrice);

        console.log("amountInUSD => ", amountInUSD);
        
        uint256 amountToMint = itemPricesUSD[itemId].div(amountInUSD);

        console.log("amountToMint => ", amountToMint);

        if(contributors[msg.sender] != 0) {
            contributors[msg.sender] += amountInUSD;
        } else {
            contributors[msg.sender] = amountInUSD;
        }

        mintOnDonation(itemId, amountToMint, msg.sender);
    }

    /*
    * if people accidentally pay ETH to this contract, admin can withdraw to beneficiary address
    * anyone can call this
    */
    function withdraw() public {
        beneficiary.transfer(address(this).balance);

        emit Withdraw(beneficiary, address(this).balance);
    }

    // this contract can receive ETH
    receive() external payable {}
    fallback() external payable {}
}
