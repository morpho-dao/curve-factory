// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IDepositZapMorphoAaveV2USD} from "src/interfaces/IDepositZapMorphoAaveV2USD.sol";

import {BaseTest} from "./BaseTest.sol";
import {Vyper} from "./Vyper.sol";

contract TestDepositZapMorphoAaveV2USD is BaseTest {
    IDepositZapMorphoAaveV2USD zap;

    function setUp() public {
        zap = IDepositZapMorphoAaveV2USD(Vyper.deploy("DepositZapMorphoAaveV2USD"));
    }

    function test() public {}
}
