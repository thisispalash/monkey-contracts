// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Recipe} from "../Recipe.sol";
import {IStacker} from "./IStacker.sol";

import {IMonkey} from "../../monkey/IMonkey.sol";

contract Stacker is Recipe, IStacker {

  Data public data;

  function initialize(address _creator, string memory _identifier, Data memory _data) external {
    __Recipe_init(_identifier, _creator);
    data = _data;
    emit StackerInitialized(
      data.royalties,
      data.pool,
      data.poolFee,
      data.tokenA,
      data.tokenB,
      data.min,
      data.max,
      data.amount
    );
  }

  /**
   * @notice Run the stacker
   * 
   * @param _stack Whether to stack or unstack, ie, buy or sell
   */
  function run(bool _stack) external override {

    uint256 amountSentToUniswap;
    address tokenSentToUniswap;

    if (_stack) {
      tokenSentToUniswap = data.tokenB;
    } else {
      tokenSentToUniswap = data.tokenA;
    }

    // execute for all copiers
    for(uint256 i=0; i<tokenId; i++) {
      address monkey = ownerOf(i);
      uint256 balance = IERC20(tokenSentToUniswap).balanceOf(monkey);

      if (balance <= 0) { continue; }

      amountSentToUniswap = balance * data.amount / 1000000;

      if (amountSentToUniswap <= 0) { continue; }

      if (balance < amountSentToUniswap) { continue; }

      IMonkey(monkey).execute(address(this), amountSentToUniswap, tokenSentToUniswap);
    }
  }

  function execute(uint256 _amount, address _token) external override {

    uint256 amountReceivedFromUniswap;
    address tokenReceivedFromUniswap;

    if (_token == data.tokenB) {
      amountReceivedFromUniswap = buy(_amount);
      tokenReceivedFromUniswap = data.tokenA;
    } else {
      amountReceivedFromUniswap = sell(_amount);
      tokenReceivedFromUniswap = data.tokenB;
    }

    uint256 fees;

    // Compute Royalties
    fees += royalties(amountReceivedFromUniswap, tokenReceivedFromUniswap);

    // Compute Compensation
    fees += compensation(amountReceivedFromUniswap, tokenReceivedFromUniswap);
    // Pay out monkey
    IERC20(_token).transfer(msg.sender, amountReceivedFromUniswap - fees);

    emit StackerExecuted(msg.sender, tx.origin, _amount, _token, amountReceivedFromUniswap, tokenReceivedFromUniswap, fees);
  }

  function royalties(uint256 _amount, address _token) internal override returns (uint256 _royalties) {
    _royalties = _amount * data.royalties / 10000;
    IERC20(_token).transfer(creator, _royalties);
    return _royalties;
  }

  function compensation(uint256 _amount, address _token) internal override returns (uint256 _compensation) {
    _compensation = _amount * COMPENSATION_FEE / 10000;
    IERC20(_token).transfer(tx.origin, _compensation);
    return _compensation;
  }

  function buy(uint256 _amountIn) internal override returns (uint256 _amountOut) {
    _amountOut = makeSwap(data.tokenB, data.tokenA, _amountIn);
  }

  function sell(uint256 _amountIn) internal override returns (uint256 _amountOut) {
    _amountOut = makeSwap(data.tokenA, data.tokenB, _amountIn);
  }

  /**
   * Make a swap on Uniswap V3
   * 
   * @param _tokenIn The token to swap from
   * @param _tokenOut The token to swap to
   * @param _amountIn The amount of tokens to swap
   * 
   * @return _amountOut The amount of tokens received
   */
  function makeSwap(address _tokenIn, address _tokenOut, uint256 _amountIn) internal returns (uint256 _amountOut) {

    TransferHelper.safeApprove(_tokenIn, address(data.pool), _amountIn);

    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: _tokenIn,
      tokenOut: _tokenOut,
      fee: data.poolFee,
      recipient: address(this),
      deadline: block.timestamp,
      amountIn: _amountIn,
      /// @dev, for below, see https://docs.uniswap.org/contracts/v3/guides/swaps/single-swaps#swap-input-parameters
      amountOutMinimum: 0, // TODO: Add oracle price
      sqrtPriceLimitX96: 0 // TODO: Add some form of slippage protection
    });

    _amountOut = ISwapRouter(data.pool).exactInputSingle(params);
  }

  function supportsInterface(bytes4 interfaceId) public view override(Recipe) returns (bool) {
    return interfaceId == type(IStacker).interfaceId
      || super.supportsInterface(interfaceId);
  }
}
