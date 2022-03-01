//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract FundUkraine is ERC1155 {
    using SafeMath for uint;

    // Ukraine Donation Receive Address
    // Mainnet 0x165CD37b4C644C2921454429E7F9358d18A45e14
    address payable public beneficiary;

    address public  deployer;

    address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

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

    event Withdraw(address to, uint amount);

    constructor(address _beneficiary) ERC1155("https://ipfs.io/ipfs/{id}.json") {
        deployer = msg.sender;
        beneficiary = payable(_beneficiary);

        itemPricesUSD[0] = 175_203; // Javelin
        itemPricesUSD[1] = 5_100_000; // HIMARS
        itemPricesUSD[2] = 38_000; // Stinger Missile Only
        itemPricesUSD[3] = 50_000_000; // NASAMS
        itemPricesUSD[4] = 41_000; // NVGs
        itemPricesUSD[5] = 38_000; // Ammo

    }

    function mintOnDonation(uint8 itemId, uint amount, address who) internal {
        _mint(who, itemId, amount, "");
    }

    // function donateWithEth(uint8 itemId) public payable {
    //     require(msg.value > 0, "you need to donate more than zero.");
        
        
    //     uint8 amount = itemPricesUSD[itemId].div();

    //     mintOnDonation(itemId, amount, msg.sender);
    // }

    function donateWithDai(uint8 itemId, uint usdAmount) public {
        require(usdAmount > 0, "you need to donate more than zero.");

        uint amountToMint = itemPricesUSD[itemId].div(usdAmount);

        IERC20(dai).approve(msg.sender, usdAmount);

        // transfer directly to Beneficiary 
        IERC20(dai).transferFrom(msg.sender, address(beneficiary), usdAmount);

        mintOnDonation(itemId, amountToMint, msg.sender);
    }

    /*
    * if people accidentally pay ETH to this contract, admin can withdraw to beneficiary address
    * anyone can call this
    */
    function withdraw() public {
        console.log("contract balance before => ", address(this).balance);
        
        beneficiary.transfer(address(this).balance);

        console.log("contract balance after => ", address(this).balance);

        emit Withdraw(beneficiary, address(this).balance);
    }

    // this contract can receive ETH
    receive() external payable {}
    fallback() external payable {}
}
