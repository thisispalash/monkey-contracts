// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {IRecipeFactory} from "./IRecipeFactory.sol";
import {Recipe} from "./Recipe.sol";

import {Stacker} from "./recipes/Stacker.sol";

contract RecipeFactory is IRecipeFactory, UUPSUpgradeable, OwnableUpgradeable {

  bytes32 public constant RECIPE_TYPE_STACKER = keccak256("STACKER");

  function initialize() external initializer {
    __Ownable_init(msg.sender);
    __UUPSUpgradeable_init();
  }

  function createRecipe(string memory _type) external returns (address) {

    address recipe;

    if (keccak256(bytes(_type)) == RECIPE_TYPE_STACKER) {
      recipe = _createStacker();
    } else {
      revert("Invalid recipe type");
    }

    emit RecipeDeployed(recipe, _type, msg.sender);
    return recipe;
  }


  /* Recipe Types */

  function _createStacker() internal returns (address) {
    Stacker stacker = new Stacker();
    stacker.copy(msg.sender); // 0-th token minted is the creator's
    return address(stacker);
  }


  /* Admin Stuff */

  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

  function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    return interfaceId == type(IRecipeFactory).interfaceId;
  }


  uint256[42] _gap; // can do 42 more recipes
}