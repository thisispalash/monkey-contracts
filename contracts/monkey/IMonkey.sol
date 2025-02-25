// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IMonkey is IERC721Receiver {

  event FundsDeposited(uint256 indexed amount, address indexed token);
  event FundsWithdrawn(uint256 indexed amount, address indexed token);

  event RecipeStarted(address indexed recipe);
  event RecipePaused(address indexed recipe);

  event RecipeExecuted(address indexed recipe, address indexed executor);
  
  function deposit(uint256 _amount, address _token) external payable;
  function withdraw(uint256 _amount, address _token) external;

  function activate(address _recipe) external;
  function deactivate(address _recipe) external;
  function execute(address _recipe, uint256 _amount, address _token) external returns (bool);

  function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4);


  /**
   * @notice: Do this when actually implementing 4337
   * 
   * function execute(address _recipe) external;
   */
}
