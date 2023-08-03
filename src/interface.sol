// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function withdraw(uint256 wad) external;
  function deposit(uint256 wad) external returns (bool);
  function owner() external view virtual returns (address);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

interface IWFTM is IERC20Metadata {
  event Deposit(address indexed dst, uint wad);
  event Withdrawal(address indexed src, uint wad);
  receive() external payable;
  fallback () external payable;
  function deposit() external payable;
  function withdraw(uint wad) external;
}

interface IBalancerVault {
  enum SwapKind { GIVEN_IN, GIVEN_OUT }
  struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }
  struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }
  function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    )
        external
        payable
        returns(uint256 amountCalculated);
  struct JoinPoolRequest {
        address[] asset;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

  struct ExitPoolRequest {
        address[] asset;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

  function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;
  
  function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external payable;

  function flashLoan(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bytes memory userData
  ) external;
}

interface ICurvePool {
  function A() external view returns (uint256 out);

  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount)
  external payable returns(uint256);

  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount)
  external returns(uint256);

  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount)
  external returns(uint256);

  function admin_fee() external view returns (uint256 out);

  function balances(uint256 arg0) external view returns (uint256 out);

  function calc_token_amount(uint256[] memory amounts, bool is_deposit)
  external
  view
  returns (uint256 lp_tokens);

  /// @dev vyper upgrade changed this on us
  function coins(int128 arg0) external view returns (address out);

  /// @dev vyper upgrade changed this on us
  function coins(uint256 arg0) external view returns (address out);

  /// @dev vyper upgrade changed this on us
  function underlying_coins(int128 arg0) external view returns (address out);

  /// @dev vyper upgrade changed this on us
  function underlying_coins(uint256 arg0) external view returns (address out);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external payable;

  // newer pools have this improved version of exchange_underlying
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy,
    address receiver
  ) external returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy,
    bool use_eth,
    address receiver
  ) external returns (uint256);

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function exchange_underlying(
      address pool,
      int128 i,
      int128 j,
      uint256 dx,
      uint256 min_dy
  ) external;

  function fee() external view returns (uint256 out);

  function future_A() external view returns (uint256 out);

  function future_fee() external view returns (uint256 out);

  function future_admin_fee() external view returns (uint256 out);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_virtual_price() external view returns (uint256 out);

  function remove_liquidity(uint256 token_amount, uint256[2] memory min_amounts)
  external
  returns (uint256[2] memory);

  function remove_liquidity(uint256 token_amount, uint256[3] memory min_amounts)
  external
  returns (uint256[3] memory);

  function remove_liquidity_imbalance(
    uint256[3] memory amounts,
    uint256 max_burn_amount
  ) external;

  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external;
}