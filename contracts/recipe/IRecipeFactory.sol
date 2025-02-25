// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

interface IRecipeFactory {

  event RecipeDeployed(address indexed _recipe, string indexed _type, address indexed _creator);
  
  /**
   * @notice Create a new recipe of type `_type`
   * @dev each type has its own deployment function, those are internal;
   *      as a result, the contracts once deployed must be initialized
   * 
   * @param _type The type of recipe to create
   * @return The address of the new recipe
   */
  function createRecipe(string memory _type) external returns (address);
}
