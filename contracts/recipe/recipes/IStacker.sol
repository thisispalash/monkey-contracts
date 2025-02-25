// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IRecipe} from "../IRecipe.sol";

interface IStacker is IRecipe {

  struct Data {
    address pool; // pool to trade with, eg, WRBTC/rUSDT
    address tokenA; // token to trade, eg, WRBTC
    address tokenB; // token denominator, eg, rUSDT
    uint256 min; // buy price, will convert tokenB to tokenA
    uint256 max; // sell price, will convert tokenA to tokenB
    uint24 amount; // % of balance to use, 1000000 = 100%
    uint24 poolFee; // pool fee, eg, 3000 for 0.3%
    uint24 royalties; // royalties, max 2.5%
  }

  event StackerInitialized(uint24 indexed royalties, address indexed pool, uint24 indexed poolFee, address tokenA, address tokenB, uint256 min, uint256 max, uint256 amount);
  event StackerExecuted(address indexed monkey, address indexed executor, uint256 amountIn, address tokenIn, uint256 amountOut, address tokenOut, uint256 fees);

  function initialize(address _creator, string memory _identifier, Data memory _data) external;

  // function supportsInterface(bytes4 interfaceId) external view override returns (bool);

}
