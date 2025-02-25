// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

interface IRecipe {

  event MonkeyAdded(address indexed monkey, uint256 indexed tokenId);
  event RecipeExecuted(address indexed monkey, address indexed executor);

  // function __Recipe_init(string memory _identifier, address _creator) external;

  function copy(address _monkey) external;

  function run(bool _stack) external;
  function execute(uint256 _amount, address _token) external;

  // function supportsInterface(bytes4 interfaceId) external view returns (bool);
}