// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IDepositZapMorphoAaveV2USD {
    function add_liquidity(address pool, uint256[] calldata amounts, uint256 minAmount) external;
    function add_liquidity(address pool, uint256[] calldata amounts, uint256 minAmount, address receiver) external;

    function remove_liquidity(address pool, uint256 amount, uint256[] calldata minAmounts) external;
    function remove_liquidity(address pool, uint256 amount, uint256[] calldata minAmounts, address receiver) external;

    function remove_liquidity_one_coin(address pool, uint256 amount, uint256 i, uint256 minAmount) external;
    function remove_liquidity_one_coin(address pool, uint256 amount, uint256 i, uint256 minAmount, address receiver)
        external;

    function remove_liquidity_imbalanced(address pool, uint256[] calldata amounts, uint256 maxAmount) external;
    function remove_liquidity_imbalanced(address pool, uint256[] calldata amounts, uint256 maxAmount, address receiver)
        external;

    function calc_withdraw_one_coin(address pool, uint256 amount, int128 i) external;
    function calc_token_amount(address pool, uint256[] calldata amounts, bool isDeposit) external;
}
