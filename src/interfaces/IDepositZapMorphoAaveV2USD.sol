// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

uint256 constant BASE_N_COINS = 3;

interface IDepositZapMorphoAaveV2USD {
    function add_liquidity(uint256[BASE_N_COINS] calldata amounts, uint256 minAmount) external returns (uint256);
    function add_liquidity(uint256[BASE_N_COINS] calldata amounts, uint256 minAmount, address receiver)
        external
        returns (uint256);

    function remove_liquidity(uint256 amount, uint256[BASE_N_COINS] calldata minAmounts)
        external
        returns (uint256[BASE_N_COINS] memory);
    function remove_liquidity(uint256 amount, uint256[BASE_N_COINS] calldata minAmounts, address receiver)
        external
        returns (uint256[BASE_N_COINS] memory);

    function remove_liquidity_one_coin(uint256 amount, int128 i, uint256 minAmount) external returns (uint256);
    function remove_liquidity_one_coin(uint256 amount, int128 i, uint256 minAmount, address receiver)
        external
        returns (uint256);

    function remove_liquidity_imbalance(uint256[BASE_N_COINS] calldata amounts, uint256 maxAmount)
        external
        returns (uint256);
    function remove_liquidity_imbalance(uint256[BASE_N_COINS] calldata amounts, uint256 maxAmount, address receiver)
        external
        returns (uint256);

    function calc_withdraw_one_coin(uint256 amount, int128 i) external returns (uint256);
    function calc_token_amount(uint256[BASE_N_COINS] calldata amounts, bool isDeposit) external returns (uint256);
}
