import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { FundUkraine } from "../typechain";

describe("FundUkraine", function () {
  let Alice: SignerWithAddress;
  let Bob: SignerWithAddress;
  let Charlie: SignerWithAddress;

  before(async () => {
    const signers = await ethers.getSigners();

    Alice = signers[0];
    Bob = signers[1];
    Charlie = signers[2];
  });

  it("Should deploy", async function () {
    const FundUkraine = await ethers.getContractFactory("FundUkraine");
    const ukraine: FundUkraine = await FundUkraine.deploy();
    await ukraine.deployed();

    expect(await ukraine.deployer()).to.equal(Alice.address);
  });
});
