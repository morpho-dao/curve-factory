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

    address internal constant INITIAL_DEPOSITOR = address(1);
    uint256 initialSupply;

    function _boundReceiver(address receiver) internal view returns (address) {
        receiver = _boundAddressNotZero(receiver);

        vm.assume(receiver != INITIAL_DEPOSITOR);

        return receiver;
    }

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

        initialSupply = zap.add_liquidity(INITIAL_DEPOSITS, 0, INITIAL_DEPOSITOR);
    }

    function _assertNoDust() internal {
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

    function testDepositDAIOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = INITIAL_DEPOSIT_DAI;

        uint256[BASE_N_COINS] memory amounts = [amount, 0, 0];
        uint256 expectedLp = zap.calc_token_amount(amounts, true).percentSub(2);

        deal(address(DAI), address(this), amount);
        ERC20(DAI).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(amounts, expectedLp, receiver);

        assertApproxGeAbs(lp, expectedLp, 1e15, "lp != expected");

        assertEq(ERC20(POOL).balanceOf(receiver), lp, "lp");
        assertEq(ERC20(POOL).balanceOf(INITIAL_DEPOSITOR), initialSupply, "initialSupply");

        _assertNoDust();
    }

    function testDepositUSDCOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = INITIAL_DEPOSIT_USDC;

        uint256[BASE_N_COINS] memory amounts = [0, amount, 0];
        uint256 expectedLp = zap.calc_token_amount(amounts, true).percentSub(2);

        deal(address(USDC), address(this), amount);
        ERC20(USDC).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(amounts, expectedLp, receiver);

        assertApproxGeAbs(lp, expectedLp, 1e15, "lp != expected");

        assertEq(ERC20(POOL).balanceOf(receiver), lp, "lp");
        assertEq(ERC20(POOL).balanceOf(INITIAL_DEPOSITOR), initialSupply, "initialSupply");

        _assertNoDust();
    }

    function testDepositUSDTOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = INITIAL_DEPOSIT_USDT;

        uint256[BASE_N_COINS] memory amounts = [0, 0, amount];
        uint256 expectedLp = zap.calc_token_amount(amounts, true).percentSub(3);

        deal(address(USDT), address(this), amount);
        ERC20(USDT).safeApprove(address(zap), amount);
        uint256 lp = zap.add_liquidity(amounts, expectedLp, receiver);

        assertApproxGeAbs(lp, expectedLp, 1e17, "lp != expected");

        assertEq(ERC20(POOL).balanceOf(receiver), lp, "lp");
        assertEq(ERC20(POOL).balanceOf(INITIAL_DEPOSITOR), initialSupply, "initialSupply");

        _assertNoDust();
    }

    function testDepositBalanced(address receiver) public {
        receiver = _boundReceiver(receiver);

        uint256 expectedLp = zap.calc_token_amount(INITIAL_DEPOSITS, true).percentSub(2);

        deal(DAI, address(this), INITIAL_DEPOSIT_DAI);
        deal(USDC, address(this), INITIAL_DEPOSIT_USDC);
        deal(USDT, address(this), INITIAL_DEPOSIT_USDT);

        ERC20(DAI).safeApprove(address(zap), INITIAL_DEPOSIT_DAI);
        ERC20(USDC).safeApprove(address(zap), INITIAL_DEPOSIT_USDC);
        ERC20(USDT).safeApprove(address(zap), INITIAL_DEPOSIT_USDT);

        uint256 lp = zap.add_liquidity(INITIAL_DEPOSITS, expectedLp, receiver);

        assertApproxGeAbs(lp, expectedLp, 1e18, "lp != expected");
        assertApproxEqAbs(lp, initialSupply, 1, "lp != initialSupply");

        assertEq(ERC20(POOL).balanceOf(receiver), lp, "lp");
        assertEq(ERC20(POOL).balanceOf(INITIAL_DEPOSITOR), initialSupply, "initialSupply");

        _assertNoDust();
    }

    function testRemoveLiquidity(address receiver) public {
        receiver = _boundReceiver(receiver);

        uint256 daiBalanceBefore = ERC20(DAI).balanceOf(receiver);
        uint256 usdcBalanceBefore = ERC20(USDC).balanceOf(receiver);
        uint256 usdtBalanceBefore = ERC20(USDT).balanceOf(receiver);

        vm.startPrank(INITIAL_DEPOSITOR);
        ERC20(POOL).safeApprove(address(zap), initialSupply);
        uint256[BASE_N_COINS] memory amounts =
            zap.remove_liquidity(initialSupply, [uint256(0), uint256(0), uint256(0)], receiver);
        vm.stopPrank();

        assertApproxLeAbs(amounts[0], INITIAL_DEPOSIT_DAI, 1, "amounts[0]");
        assertApproxLeAbs(amounts[1], INITIAL_DEPOSIT_USDC, 1, "amounts[1]");
        assertApproxLeAbs(amounts[2], INITIAL_DEPOSIT_USDT, 1, "amounts[2]");

        assertEq(ERC20(DAI).balanceOf(receiver), daiBalanceBefore + amounts[0], "DAI");
        assertEq(ERC20(USDC).balanceOf(receiver), usdcBalanceBefore + amounts[1], "USDC");
        assertEq(ERC20(USDT).balanceOf(receiver), usdtBalanceBefore + amounts[2], "USDT");

        _assertNoDust();
    }

    function testRemoveLiquidityDAIOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = initialSupply / 3;

        uint256 daiBalanceBefore = ERC20(DAI).balanceOf(receiver);
        uint256 expectedDaiAmount = zap.calc_withdraw_one_coin(amount, 0);

        vm.startPrank(INITIAL_DEPOSITOR);
        ERC20(POOL).safeApprove(address(zap), amount);
        uint256 daiAmount = zap.remove_liquidity_one_coin(amount, 0, expectedDaiAmount, receiver);
        vm.stopPrank();

        assertGe(daiAmount, expectedDaiAmount, "dai < expected");
        assertLe(daiAmount, INITIAL_DEPOSIT_DAI, "dai > initialDeposit");

        assertEq(ERC20(DAI).balanceOf(receiver), daiBalanceBefore + daiAmount, "DAI");

        _assertNoDust();
    }

    function testRemoveLiquidityUSDCOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = initialSupply / 3;

        uint256 usdcBalanceBefore = ERC20(USDC).balanceOf(receiver);
        uint256 expectedUsdcAmount = zap.calc_withdraw_one_coin(amount, 1);

        vm.startPrank(INITIAL_DEPOSITOR);
        ERC20(POOL).safeApprove(address(zap), amount);
        uint256 usdcAmount = zap.remove_liquidity_one_coin(amount, 1, expectedUsdcAmount, receiver);
        vm.stopPrank();

        assertGe(usdcAmount, expectedUsdcAmount, "usdc < expected");
        assertLe(usdcAmount, INITIAL_DEPOSIT_USDC, "usdc > initialDeposit");

        assertEq(ERC20(USDC).balanceOf(receiver), usdcBalanceBefore + usdcAmount, "USDC");

        _assertNoDust();
    }

    function testRemoveLiquidityUSDTOnly(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256 amount = initialSupply / 3;

        uint256 usdtBalanceBefore = ERC20(USDT).balanceOf(receiver);
        uint256 expectedUsdtAmount = zap.calc_withdraw_one_coin(amount, 2);

        vm.startPrank(INITIAL_DEPOSITOR);
        ERC20(POOL).safeApprove(address(zap), amount);
        uint256 usdtAmount = zap.remove_liquidity_one_coin(amount, 2, expectedUsdtAmount, receiver);
        vm.stopPrank();

        assertGe(usdtAmount, expectedUsdtAmount, "usdt < expected");
        assertLe(usdtAmount, INITIAL_DEPOSIT_USDT, "usdt > initialDeposit");

        assertEq(ERC20(USDT).balanceOf(receiver), usdtBalanceBefore + usdtAmount, "USDT");

        _assertNoDust();
    }

    function testRemoveLiquidityImbalanced(address receiver) public {
        receiver = _boundReceiver(receiver);
        uint256[BASE_N_COINS] memory amounts = [INITIAL_DEPOSIT_DAI / 2, INITIAL_DEPOSIT_USDC / 4, 0];

        uint256 daiBalanceBefore = ERC20(DAI).balanceOf(receiver);
        uint256 usdcBalanceBefore = ERC20(USDC).balanceOf(receiver);
        uint256 expectedLp = zap.calc_token_amount(amounts, false).percentAdd(1);

        vm.startPrank(INITIAL_DEPOSITOR);
        ERC20(POOL).safeApprove(address(zap), expectedLp);
        uint256 lp = zap.remove_liquidity_imbalance(amounts, expectedLp, receiver);
        vm.stopPrank();

        assertApproxLeAbs(lp, expectedLp, 1e16, "lp < expected");

        assertEq(ERC20(POOL).balanceOf(INITIAL_DEPOSITOR), initialSupply - lp, "lp");
        assertEq(ERC20(DAI).balanceOf(receiver), daiBalanceBefore + amounts[0], "DAI");
        assertEq(ERC20(USDC).balanceOf(receiver), usdcBalanceBefore + amounts[1], "USDC");

        _assertNoDust();
    }
}
