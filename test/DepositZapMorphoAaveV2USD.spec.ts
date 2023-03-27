import { expect } from "chai";
import { BigNumber, BigNumberish, constants } from "ethers";
import hre, { ethers } from "hardhat";
import { deal } from "hardhat-deal";

import { setNextBlockBaseFeePerGas, SnapshotRestorer, takeSnapshot } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import { ERC20, ERC20__factory } from "@morpho-labs/morpho-ethers-contract";

import { DepositZapMorphoAaveV2USD } from "types";

hre.config.tracer.nameTags["0x777777c9898d384f785ee44acfe945efdff5f3e0"] = "MorphoAaveV2";

const initialDepositDai = BigNumber.WAD.mul(1_000);
const initialDepositUsdc = BigNumber.pow10(6).mul(1_000);
const initialDepositUsdt = BigNumber.pow10(6).mul(1_000);

describe("DepositZapMorphoAaveV2USD", () => {
  let user: SignerWithAddress;
  let deployer: SignerWithAddress;
  let zap: DepositZapMorphoAaveV2USD;

  let dai: ERC20;
  let usdc: ERC20;
  let usdt: ERC20;

  let maDai: ERC20;
  let maUsdc: ERC20;
  let maUsdt: ERC20;

  let pool: ERC20;
  let initialSupply: BigNumber;

  let snapshot: SnapshotRestorer;

  beforeEach(async () => {
    [deployer, user] = await ethers.getSigners();

    await setNextBlockBaseFeePerGas(0);

    // Deploy Zap

    const factory = await hre.ethers.getContractFactory("DepositZapMorphoAaveV2USD");

    zap = await factory.deploy();

    // Initialize variables

    zap = zap.connect(user);

    dai = ERC20__factory.connect("0x6B175474E89094C44Da98b954EedeAC495271d0F", user);
    usdc = ERC20__factory.connect("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", user);
    usdt = ERC20__factory.connect("0xdAC17F958D2ee523a2206206994597C13D831ec7", user);

    maDai = ERC20__factory.connect("0x36F8d0D0573ae92326827C4a82Fe4CE4C244cAb6", user);
    maUsdc = ERC20__factory.connect("0xA5269A8e31B93Ff27B887B56720A25F844db0529", user);
    maUsdt = ERC20__factory.connect("0xAFe7131a57E44f832cb2dE78ade38CaD644aaC2f", user);

    pool = ERC20__factory.connect("0xddA1B81690b530DE3C48B3593923DF0A6C5fe92E", user);

    // Deal coins

    await deal(dai.address, user.address, initialDepositDai.mul(100));
    await deal(usdc.address, user.address, initialDepositUsdc.mul(100));
    await deal(usdt.address, user.address, initialDepositUsdt.mul(100));

    // Pool initial deposit

    await deal(dai.address, deployer.address, initialDepositDai);
    await deal(usdc.address, deployer.address, initialDepositUsdc);
    await deal(usdt.address, deployer.address, initialDepositUsdt);

    await dai.connect(deployer).approve(zap.address, initialDepositDai);
    await usdc.connect(deployer).approve(zap.address, initialDepositUsdc);
    await usdt.connect(deployer).approve(zap.address, initialDepositUsdt);

    await zap
      .connect(deployer)
      ["add_liquidity(address,uint256[3],uint256,address)"](
        pool.address,
        [initialDepositDai, initialDepositUsdc, initialDepositUsdt],
        0,
        constants.AddressZero
      );

    initialSupply = await pool.balanceOf(constants.AddressZero);

    snapshot = await takeSnapshot();
  });

  afterEach(async () => {
    await snapshot.restore();
  });

  it("should deposit DAI alone", async () => {
    await dai.approve(zap.address, initialDepositDai);

    const amounts: [BigNumberish, BigNumberish, BigNumberish] = [initialDepositDai, 0, 0];

    const expLpAmount = (await zap.calc_token_amount(pool.address, amounts, true)).percentSub(2);

    await zap["add_liquidity(address,uint256[3],uint256)"](pool.address, amounts, expLpAmount);

    expect((await pool.balanceOf(user.address)).formatWad(2)).eq(expLpAmount.formatWad(2));
    expect((await pool.balanceOf(deployer.address)).formatWad(0)).eq("0");
    expect((await pool.balanceOf(constants.AddressZero)).toString()).eq(initialSupply.toString());

    expect((await maDai.balanceOf(zap.address)).toString()).eq("0", "zap maDAI");
    expect((await maUsdc.balanceOf(zap.address)).toString()).eq("0", "zap maUSDC");
    expect((await maUsdt.balanceOf(zap.address)).toString()).eq("0", "zap maUSDT");

    expect((await maDai.balanceOf(user.address)).toString()).eq("0", "user maDAI");
    expect((await maUsdc.balanceOf(user.address)).toString()).eq("0", "user maUSDC");
    expect((await maUsdt.balanceOf(user.address)).toString()).eq("0", "user maUSDT");
  });

  it("should deposit USDC alone", async () => {
    await usdc.approve(zap.address, initialDepositUsdc);

    const amounts: [BigNumberish, BigNumberish, BigNumberish] = [0, initialDepositUsdc, 0];

    const expLpAmount = (await zap.calc_token_amount(pool.address, amounts, true)).percentSub(2);

    await zap["add_liquidity(address,uint256[3],uint256)"](pool.address, amounts, expLpAmount);

    expect((await pool.balanceOf(user.address)).formatWad(2)).eq(expLpAmount.formatWad(2));
    expect((await pool.balanceOf(deployer.address)).formatWad(0)).eq("0");
    expect((await pool.balanceOf(constants.AddressZero)).toString()).eq(initialSupply.toString());

    expect((await maDai.balanceOf(zap.address)).toString()).eq("0", "zap maDAI");
    expect((await maUsdc.balanceOf(zap.address)).toString()).eq("0", "zap maUSDC");
    expect((await maUsdt.balanceOf(zap.address)).toString()).eq("0", "zap maUSDT");

    expect((await maDai.balanceOf(user.address)).toString()).eq("0", "user maDAI");
    expect((await maUsdc.balanceOf(user.address)).toString()).eq("0", "user maUSDC");
    expect((await maUsdt.balanceOf(user.address)).toString()).eq("0", "user maUSDT");
  });

  it("should deposit USDT alone", async () => {
    await usdt.approve(zap.address, initialDepositUsdt);

    const amounts: [BigNumberish, BigNumberish, BigNumberish] = [0, 0, initialDepositUsdt];

    const expLpAmount = (await zap.calc_token_amount(pool.address, amounts, true)).percentSub(3);

    await zap["add_liquidity(address,uint256[3],uint256)"](pool.address, amounts, expLpAmount);

    expect((await pool.balanceOf(user.address)).formatWad(2)).eq(expLpAmount.formatWad(2));
    expect((await pool.balanceOf(deployer.address)).formatWad(0)).eq("0");
    expect((await pool.balanceOf(constants.AddressZero)).toString()).eq(initialSupply.toString());

    expect((await maDai.balanceOf(zap.address)).toString()).eq("0", "zap maDAI");
    expect((await maUsdc.balanceOf(zap.address)).toString()).eq("0", "zap maUSDC");
    expect((await maUsdt.balanceOf(zap.address)).toString()).eq("0", "zap maUSDT");

    expect((await maDai.balanceOf(user.address)).toString()).eq("0", "user maDAI");
    expect((await maUsdc.balanceOf(user.address)).toString()).eq("0", "user maUSDC");
    expect((await maUsdt.balanceOf(user.address)).toString()).eq("0", "user maUSDT");
  });

  it("should deposit balanced", async () => {
    await dai.approve(zap.address, initialDepositDai);
    await usdc.approve(zap.address, initialDepositUsdc);
    await usdt.approve(zap.address, initialDepositUsdt);

    const amounts: [BigNumberish, BigNumberish, BigNumberish] = [
      initialDepositDai,
      initialDepositUsdc,
      initialDepositUsdt,
    ];

    const expLpAmount = (await zap.calc_token_amount(pool.address, amounts, true)).percentSub(2);

    await zap["add_liquidity(address,uint256[3],uint256)"](pool.address, amounts, expLpAmount);

    expect((await pool.balanceOf(user.address)).formatWad(2)).eq(expLpAmount.formatWad(2));
    expect((await pool.balanceOf(deployer.address)).formatWad(0)).eq("0");
    expect((await pool.balanceOf(constants.AddressZero)).toString()).eq(initialSupply.toString());

    expect((await maDai.balanceOf(zap.address)).toString()).eq("0", "zap maDAI");
    expect((await maUsdc.balanceOf(zap.address)).toString()).eq("0", "zap maUSDC");
    expect((await maUsdt.balanceOf(zap.address)).toString()).eq("0", "zap maUSDT");

    expect((await maDai.balanceOf(user.address)).toString()).eq("0", "user maDAI");
    expect((await maUsdc.balanceOf(user.address)).toString()).eq("0", "user maUSDC");
    expect((await maUsdt.balanceOf(user.address)).toString()).eq("0", "user maUSDT");
  });
});
