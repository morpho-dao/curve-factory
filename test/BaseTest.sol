// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {WadRayMath} from "@morpho-utils/math/WadRayMath.sol";
import {PercentageMath} from "@morpho-utils/math/PercentageMath.sol";

import {stdStorage, StdStorage} from "@forge-std/StdStorage.sol";
import {console2 as console} from "@forge-std/console2.sol";
import {Test} from "@forge-std/Test.sol";

contract BaseTest is Test {
    uint256 internal constant BLOCK_TIME = 12;
    uint256 internal constant DEFAULT_MAX_ITERATIONS = 10;

    uint256 private constant MAX_AMOUNT = 1e20 ether;

    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address internal constant MA_DAI = 0x36F8d0D0573ae92326827C4a82Fe4CE4C244cAb6;
    address internal constant MA_USDC = 0xA5269A8e31B93Ff27B887B56720A25F844db0529;
    address internal constant MA_USDT = 0xAFe7131a57E44f832cb2dE78ade38CaD644aaC2f;

    address internal constant POOL = 0xddA1B81690b530DE3C48B3593923DF0A6C5fe92E;

    function setUp() public virtual {
        Chain memory chain = getChain("mainnet");

        vm.createSelectFork(chain.rpcUrl, 16_600_000);
        vm.chainId(chain.chainId);

        vm.label(DAI, "DAI");
        vm.label(USDC, "USDC");
        vm.label(USDT, "USDT");

        vm.label(MA_DAI, "maDAI");
        vm.label(MA_USDC, "maUSDC");
        vm.label(MA_USDT, "maUSDT");

        vm.label(POOL, "Pool");
    }

    /// @dev Asserts a is approximately less than or equal to b, with a maximum absolute difference of maxDelta.
    function assertApproxLeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
        assertLe(a, b, err);
        assertApproxEqAbs(a, b, maxDelta, err);
    }

    /// @dev Asserts a is approximately greater than or equal to b, with a maximum absolute difference of maxDelta.
    function assertApproxGeAbs(uint256 a, uint256 b, uint256 maxDelta, string memory err) internal {
        assertGe(a, b, err);
        assertApproxEqAbs(a, b, maxDelta, err);
    }

    /// @dev Rolls & warps the given number of blocks forward the blockchain.
    function _forward(uint256 blocks) internal {
        vm.roll(block.number + blocks);
        vm.warp(block.timestamp + blocks * BLOCK_TIME); // Block speed should depend on test network.
    }

    /// @dev Bounds the fuzzing input to a realistic number of blocks.
    function _boundBlocks(uint256 blocks) internal view returns (uint256) {
        return bound(blocks, 1, type(uint24).max);
    }

    /// @dev Bounds the fuzzing input to a realistic index.
    function _boundIndex(uint256 index) internal view returns (uint256) {
        return bound(index, WadRayMath.RAY, 20 * WadRayMath.RAY);
    }

    /// @dev Bounds the fuzzing input to a realistic amount.
    function _boundAmount(uint256 amount) internal view virtual returns (uint256) {
        return bound(amount, 0, MAX_AMOUNT);
    }

    /// @dev Bounds the fuzzing input to a realistic amount.
    function _boundAmountNotZero(uint256 amount) internal view virtual returns (uint256) {
        return bound(amount, 1, MAX_AMOUNT);
    }

    /// @dev Bounds the fuzzing input to a non-zero 256 bits unsigned integer.
    function _boundNotZero(uint256 input) internal view virtual returns (uint256) {
        return bound(input, 1, type(uint256).max);
    }

    /// @dev Bounds the fuzzing input to a non-zero address.
    function _boundAddressNotZero(address input) internal view virtual returns (address) {
        return address(uint160(bound(uint256(uint160(input)), 1, type(uint160).max)));
    }

    /// @dev Assumes the receiver is able to receive ETH without reverting.
    function _assumeETHReceiver(address receiver) internal {
        (bool success,) = receiver.call("");
        vm.assume(success);
    }
}
