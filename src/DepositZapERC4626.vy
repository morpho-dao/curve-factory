# @version 0.2.15
"""
@title "Zap" Depositer for permissionless Morpho-Aave V2 USD metapools
@author Morpho Labs
@license Copyright (c) Morpho Labs, 2023 - all rights reserved
"""

interface ERC20:
    def transfer(_receiver: address, amount: uint256): nonpayable
    def transferFrom(_sender: address, _receiver: address, amount: uint256): nonpayable
    def approve(spender: address, amount: uint256): nonpayable
    def decimals() -> uint256: view
    def balanceOf(owner: address) -> uint256: view

interface CurveBase:
    def add_liquidity(amounts: uint256[BASE_N_COINS], min_mint_amount: uint256, receiver: address) -> uint256: nonpayable
    def remove_liquidity(amount: uint256, min_amounts: uint256[BASE_N_COINS]) -> uint256[BASE_N_COINS]: nonpayable
    def remove_liquidity_one_coin(token_amount: uint256, i: int128, min_amount: uint256) -> uint256: nonpayable
    def remove_liquidity_imbalance(amounts: uint256[BASE_N_COINS], max_burn_amount: uint256) -> uint256: nonpayable
    def calc_withdraw_one_coin(token_amount: uint256, i: int128) -> uint256: view
    def calc_token_amount(amounts: uint256[BASE_N_COINS], deposit: bool) -> uint256: view
    def coins(i: uint256) -> address: view

interface ERC4626:
    def deposit(assets: uint256, receiver: address) -> uint256: nonpayable
    def redeem(shares: uint256, receiver: address, owner: address) -> uint256: nonpayable
    def previewDeposit(assets: uint256) -> uint256: view
    def previewWithdraw(assets: uint256) -> uint256: view
    def previewRedeem(shares: uint256) -> uint256: view
    def asset() -> address: view


BASE_N_COINS: constant(uint256) = 3
BASE_POOL: constant(address) = 0xddA1B81690b530DE3C48B3593923DF0A6C5fe92E

erc20_coins: public(address[BASE_N_COINS])
erc4626_coins: public(address[BASE_N_COINS])


@external
def __init__():
    """
    @notice Contract constructor
    """
    for i in range(BASE_N_COINS):
        erc4626: address = CurveBase(BASE_POOL).coins(i)
        erc20: address = ERC4626(erc4626).asset()

        self.erc20_coins[i] = erc20
        self.erc4626_coins[i] = erc4626

        ERC20(erc20).approve(erc4626, MAX_UINT256)
        ERC20(erc4626).approve(BASE_POOL, MAX_UINT256)


@view
@internal
def _calc_shares(_assets: uint256[BASE_N_COINS], _is_deposit: bool) -> uint256[BASE_N_COINS]:
    """
    @notice Calculate the number of shares equivalent to a deposit
            or a withdrawal of the given quantity of underlying coins.
    @param _assets Amount of each underlying coin being deposited/withdrawn
    @param _is_deposit set True for deposits, False for withdrawals
    @return Expected shares minted/redeemed
    """
    shares: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])

    # Convert all amounts into shares
    for i in range(BASE_N_COINS):
        erc4626_coin: address = self.erc4626_coins[i]

        if _is_deposit:
            shares[i] = ERC4626(erc4626_coin).previewDeposit(_assets[i])
        else:
            shares[i] = ERC4626(erc4626_coin).previewWithdraw(_assets[i])

    return shares


@external
def add_liquidity(
    _deposit_amounts: uint256[BASE_N_COINS],
    _min_mint_amount: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Wrap underlying coins and deposit them into `_pool`
    @param _pool Address of the pool to deposit into
    @param _deposit_amounts List of amounts of underlying coins to deposit
    @param _min_mint_amount Minimum amount of LP tokens to mint from the deposit
    @param _receiver Address that receives the LP tokens
    @return Amount of LP tokens received by depositing
    """
    shares: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])

    # Deposit all coins into vaults
    for i in range(BASE_N_COINS):
        amount: uint256 = _deposit_amounts[i]
        if amount == 0:
            continue

        erc20_coin: address = self.erc20_coins[i]
        erc4626_coin: address = self.erc4626_coins[i]

        ERC20(erc20_coin).transferFrom(msg.sender, self, amount)
        shares[i] = ERC4626(erc4626_coin).deposit(amount, self)

    # Deposit to the base pool
    return CurveBase(BASE_POOL).add_liquidity(shares, _min_mint_amount, _receiver)


@external
def remove_liquidity(
    _burn_amount: uint256,
    _min_amounts: uint256[BASE_N_COINS],
    _receiver: address = msg.sender
) -> uint256[BASE_N_COINS]:
    """
    @notice Withdraw and unwrap coins from the pool
    @dev Withdrawal amounts are based on current deposit ratios
    @param _pool Address of the pool to deposit into
    @param _burn_amount Quantity of LP tokens to burn in the withdrawal
    @param _min_amounts Minimum amounts of underlying coins to receive
    @param _receiver Address that receives the LP tokens
    @return List of amounts of underlying coins that were withdrawn
    """
    ERC20(BASE_POOL).transferFrom(msg.sender, self, _burn_amount)

    min_shares: uint256[BASE_N_COINS] = self._calc_shares(_min_amounts, False)

    # Withdraw from base
    base_shares: uint256[BASE_N_COINS] = CurveBase(BASE_POOL).remove_liquidity(_burn_amount, min_shares)

    # Withdraw all coins from vaults
    amounts: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
    for i in range(BASE_N_COINS):
        shares: uint256 = base_shares[i]
        if shares == 0:
            continue

        erc4626_coin: address = self.erc4626_coins[i]

        amounts[i] = ERC4626(erc4626_coin).redeem(shares, _receiver, self)

    return amounts


@external
def remove_liquidity_one_coin(
    _burn_amount: uint256,
    i: int128,
    _min_amount: uint256,
    _receiver: address = msg.sender
) -> uint256:
    """
    @notice Withdraw and unwrap a single coin from the pool
    @param _pool Address of the pool to deposit into
    @param _burn_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the coin to withdraw
    @param _min_amount Minimum amount of underlying coin to receive
    @param _receiver Address that receives the LP tokens
    @return Amount of underlying coin received
    """
    ERC20(BASE_POOL).transferFrom(msg.sender, self, _burn_amount)

    erc4626_coin: address = self.erc4626_coins[i]

    min_shares: uint256 = ERC4626(erc4626_coin).previewWithdraw(_min_amount)

    # Withdraw a base pool coin
    shares: uint256 = CurveBase(BASE_POOL).remove_liquidity_one_coin(_burn_amount, i, min_shares) # does not support fee on transfer

    return ERC4626(erc4626_coin).redeem(shares, _receiver, self)


@external
def remove_liquidity_imbalance(
    _amounts: uint256[BASE_N_COINS],
    _max_burn_amount: uint256,
    _receiver: address = msg.sender
) -> uint256:
    """
    @notice Withdraw coins from the pool in an imbalanced amount
    @param _pool Address of the pool to deposit into
    @param _amounts List of amounts of underlying coins to withdraw
    @param _max_burn_amount Maximum amount of LP token to burn in the withdrawal
    @param _receiver Address that receives the LP tokens
    @return Actual amount of the LP token burned in the withdrawal
    """
    # Transfer the LP token in
    ERC20(BASE_POOL).transferFrom(msg.sender, self, _max_burn_amount)

    base_shares: uint256[BASE_N_COINS] = self._calc_shares(_amounts, False)

    # withdraw from base pool
    burn_amount: uint256 = CurveBase(BASE_POOL).remove_liquidity_imbalance(base_shares, _max_burn_amount)

    coin: address = BASE_POOL
    leftover: uint256 = ERC20(coin).balanceOf(self)

    if leftover > 0:
        # if some base pool LP tokens remain, re-transfer them to the caller
        ERC20(coin).transfer(msg.sender, leftover)

    # Transfer withdrawn base pool tokens to caller
    for i in range(BASE_N_COINS):
        shares: uint256 = base_shares[i]
        if shares == 0:
            continue

        erc4626_coin: address = self.erc4626_coins[i]

        ERC4626(erc4626_coin).redeem(shares, _receiver, self)

    return burn_amount


@view
@external
def calc_withdraw_one_coin(
    _token_amount: uint256,
    i: int128
) -> uint256:
    """
    @notice Calculate the amount received when withdrawing and unwrapping a single coin
    @param _pool Address of the pool to deposit into
    @param _token_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the underlying coin to withdraw
    @return Amount of coin received
    """
    shares: uint256 = CurveBase(BASE_POOL).calc_withdraw_one_coin(_token_amount, i)

    erc4626_coin: address = self.erc4626_coins[i]

    return ERC4626(erc4626_coin).previewRedeem(shares)


@view
@external
def calc_token_amount(
    _amounts: uint256[BASE_N_COINS],
    _is_deposit: bool
) -> uint256:
    """
    @notice Calculate addition or reduction in token supply from a deposit or withdrawal
    @dev This calculation accounts for slippage, but not fees.
         Needed to prevent front-running, not for precise calculations!
    @param _pool Address of the pool to deposit into
    @param _amounts Amount of each underlying coin being deposited/withdrawn
    @param _is_deposit set True for deposits, False for withdrawals
    @return Expected amount of LP tokens received
    """
    shares: uint256[BASE_N_COINS] = self._calc_shares(_amounts, _is_deposit)

    return CurveBase(BASE_POOL).calc_token_amount(shares, _is_deposit)
