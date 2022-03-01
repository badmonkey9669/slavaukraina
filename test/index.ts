import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import hre, { ethers } from "hardhat";

import { FundUkraine } from "../typechain";
import { ERC20Mock } from '../typechain-types';

describe("FundUkraine", function () {
  let Alice: SignerWithAddress;
  let Bob: SignerWithAddress;
  let Charlie: SignerWithAddress;

  let ukraine: FundUkraine;
  let beneficiary: SignerWithAddress;
  let mockDai: Contract;


  before(async () => {
    const signers = await ethers.getSigners();

    Alice = signers[0];
    Bob = signers[1];
    Charlie = signers[2];
    beneficiary = signers[3];
  });

  it("Should deploy", async function () {
    const ERC20MockFactory = await ethers.getContractFactory("ERC20Mock");
    mockDai = (await ERC20MockFactory.connect(Alice).deploy(
      "Mock DAI",
      "DAI",
      Bob.address,
      69e12
    )) as ERC20Mock;
    await mockDai.deployed();

    expect(await mockDai.symbol()).to.equal("DAI");

    const FundUkraine = await ethers.getContractFactory("FundUkraine");
    ukraine = await FundUkraine.connect(Alice).deploy(beneficiary.address);
    await ukraine.deployed();

    expect(await ukraine.deployer()).to.equal(Alice.address);
  });

  it("Bob should have some starting balance", async function () {
    const ethBalance = await ethers.provider.getBalance(Bob.address);

    expect(ethBalance.gt(0)).to.be.true;

    const mockDaiBalance = await mockDai.balanceOf(Bob.address);

    expect(mockDaiBalance.gt(0)).to.be.true;
  });

  it.skip("Should accept DAI to mint", async function () {

  })

  it.skip("Should accept ETH to mint", async function () {
    
  })
  
  it("Should withdraw ETH", async function () {
    const value = ethers.utils.parseEther("0.0042069");

    Alice.sendTransaction({
      to: ukraine.address,
      value
    }).then(async () => {
        expect(await ethers.provider.getBalance(ukraine.address)).to.equal(value);

        expect(await ukraine.withdraw()).to
          .emit(ukraine, 'Withdraw')
          .withArgs(beneficiary.address, value);
      })
    });
});
