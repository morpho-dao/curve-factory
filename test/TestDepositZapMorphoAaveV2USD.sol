// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IDepositZapMorphoAaveV2USD, BASE_N_COINS} from "src/interfaces/IDepositZapMorphoAaveV2USD.sol";

import {Vyper} from "./Vyper.sol";
import "./BaseTest.sol";

contract TestDepositZapMorphoAaveV2USD is BaseTest {
    using SafeTransferLib for ERC20;
    using PercentageMath for uint256;

    IDepositZapMorphoAaveV2USD zap;

    uint256 internal constant INITIAL_DEPOSIT_DAI = 1_000e18;
    uint256 internal constant INITIAL_DEPOSIT_USDC = 1_000e6;
    uint256 internal constant INITIAL_DEPOSIT_USDT = 1_000e6;

    uint256[BASE_N_COINS] internal INITIAL_DEPOSITS = [INITIAL_DEPOSIT_DAI, INITIAL_DEPOSIT_USDC, INITIAL_DEPOSIT_USDT];

    uint256 initialSupply;

    function setUp() public virtual override {
        super.setUp();

        zap = IDepositZapMorphoAaveV2USD(Vyper.deploy("DepositZapMorphoAaveV2USD"));

        vm.label(address(zap), "Zap");

        // Pool initial deposit

        deal(DAI, address(this), INITIAL_DEPOSIT_DAI);
        deal(USDC, address(this), INITIAL_DEPOSIT_USDC);
        deal(USDT, address(this), INITIAL_DEPOSIT_USDT);

        ERC20(DAI).safeApprove(address(zap), INITIAL_DEPOSIT_DAI);
        ERC20(USDC).safeApprove(address(zap), INITIAL_DEPOSIT_USDC);
        ERC20(USDT).safeApprove(address(zap), INITIAL_DEPOSIT_USDT);

        initialSupply = zap.add_liquidity(POOL, INITIAL_DEPOSITS, 0, address(0));
    }

    function testDepositDAIAlone() public {
        uint256 amount = INITIAL_DEPOSIT_DAI;

        uint256[BASE_N_COINS] memory amounts = [amount, 0, 0];
        uint256 expectedLp = zap.calc_token_amount(POOL, amounts, true).percentSub(2);

        deal(address(DAI), address(this), amount);
        ERC20(DAI).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(POOL, amounts, expectedLp);

        assertGe(lp, expectedLp, "lp < exp");
        assertApproxEqAbs(lp, expectedLp, 1e15, "lp != expectedLp");

        assertEq(ERC20(POOL).balanceOf(address(0)), initialSupply, "initialSupply");

        assertEq(ERC20(DAI).balanceOf(address(zap)), 0, "zap DAI");
        assertEq(ERC20(USDC).balanceOf(address(zap)), 0, "zap USDC");
        assertEq(ERC20(USDT).balanceOf(address(zap)), 0, "zap USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(zap)), 0, "zap maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(zap)), 0, "zap maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(zap)), 0, "zap maUSDT");

        assertEq(ERC20(DAI).balanceOf(address(this)), 0, "DAI");
        assertEq(ERC20(USDC).balanceOf(address(this)), 0, "USDC");
        assertEq(ERC20(USDT).balanceOf(address(this)), 0, "USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(this)), 0, "maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(this)), 0, "maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(this)), 0, "maUSDT");
    }

    function testDepositUSDCAlone() public {
        uint256 amount = INITIAL_DEPOSIT_USDC;

        uint256[BASE_N_COINS] memory amounts = [0, amount, 0];
        uint256 expectedLp = zap.calc_token_amount(POOL, amounts, true).percentSub(2);

        deal(address(USDC), address(this), amount);
        ERC20(USDC).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(POOL, amounts, expectedLp);

        assertGe(lp, expectedLp, "lp < exp");
        assertApproxEqAbs(lp, expectedLp, 1e15, "lp != expectedLp");

        assertEq(ERC20(POOL).balanceOf(address(0)), initialSupply, "initialSupply");

        assertEq(ERC20(DAI).balanceOf(address(zap)), 0, "zap DAI");
        assertEq(ERC20(USDC).balanceOf(address(zap)), 0, "zap USDC");
        assertEq(ERC20(USDT).balanceOf(address(zap)), 0, "zap USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(zap)), 0, "zap maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(zap)), 0, "zap maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(zap)), 0, "zap maUSDT");

        assertEq(ERC20(DAI).balanceOf(address(this)), 0, "DAI");
        assertEq(ERC20(USDC).balanceOf(address(this)), 0, "USDC");
        assertEq(ERC20(USDT).balanceOf(address(this)), 0, "USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(this)), 0, "maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(this)), 0, "maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(this)), 0, "maUSDT");
    }

    function testDepositUSDTAlone() public {
        uint256 amount = INITIAL_DEPOSIT_USDT;

        uint256[BASE_N_COINS] memory amounts = [0, 0, amount];
        uint256 expectedLp = zap.calc_token_amount(POOL, amounts, true).percentSub(3);

        deal(address(USDT), address(this), amount);
        ERC20(USDT).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(POOL, amounts, expectedLp);

        assertGe(lp, expectedLp, "lp < exp");
        assertApproxEqAbs(lp, expectedLp, 1e17, "lp != expectedLp");

        assertEq(ERC20(POOL).balanceOf(address(0)), initialSupply, "initialSupply");

        assertEq(ERC20(DAI).balanceOf(address(zap)), 0, "zap DAI");
        assertEq(ERC20(USDC).balanceOf(address(zap)), 0, "zap USDC");
        assertEq(ERC20(USDT).balanceOf(address(zap)), 0, "zap USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(zap)), 0, "zap maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(zap)), 0, "zap maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(zap)), 0, "zap maUSDT");

        assertEq(ERC20(DAI).balanceOf(address(this)), 0, "DAI");
        assertEq(ERC20(USDC).balanceOf(address(this)), 0, "USDC");
        assertEq(ERC20(USDT).balanceOf(address(this)), 0, "USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(this)), 0, "maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(this)), 0, "maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(this)), 0, "maUSDT");
    }

    function testDepositBalanced() public {
        uint256 expectedLp = zap.calc_token_amount(POOL, INITIAL_DEPOSITS, true).percentSub(2);

        deal(DAI, address(this), INITIAL_DEPOSIT_DAI);
        deal(USDC, address(this), INITIAL_DEPOSIT_USDC);
        deal(USDT, address(this), INITIAL_DEPOSIT_USDT);

        ERC20(DAI).safeApprove(address(zap), INITIAL_DEPOSIT_DAI);
        ERC20(USDC).safeApprove(address(zap), INITIAL_DEPOSIT_USDC);
        ERC20(USDT).safeApprove(address(zap), INITIAL_DEPOSIT_USDT);

        uint256 lp = zap.add_liquidity(POOL, INITIAL_DEPOSITS, expectedLp);

        assertGe(lp, expectedLp, "lp < exp");
        assertApproxEqAbs(lp, expectedLp, 1e18, "lp != expectedLp");
        assertApproxEqAbs(lp, initialSupply, 1, "lp != initialSupply");

        assertEq(ERC20(POOL).balanceOf(address(0)), initialSupply, "initialSupply");

        assertEq(ERC20(DAI).balanceOf(address(zap)), 0, "zap DAI");
        assertEq(ERC20(USDC).balanceOf(address(zap)), 0, "zap USDC");
        assertEq(ERC20(USDT).balanceOf(address(zap)), 0, "zap USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(zap)), 0, "zap maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(zap)), 0, "zap maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(zap)), 0, "zap maUSDT");

        assertEq(ERC20(DAI).balanceOf(address(this)), 0, "DAI");
        assertEq(ERC20(USDC).balanceOf(address(this)), 0, "USDC");
        assertEq(ERC20(USDT).balanceOf(address(this)), 0, "USDT");

        assertEq(ERC20(MA_DAI).balanceOf(address(this)), 0, "maDAI");
        assertEq(ERC20(MA_USDC).balanceOf(address(this)), 0, "maUSDC");
        assertEq(ERC20(MA_USDT).balanceOf(address(this)), 0, "maUSDT");
    }
}
