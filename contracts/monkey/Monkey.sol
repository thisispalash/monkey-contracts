// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {IMonkey} from "./IMonkey.sol";
import {IRecipe} from "../recipe/IRecipe.sol";

contract Monkey is IMonkey, Initializable {
  
  bytes32 public UUID;
  address private human;

  mapping(address => bool) internal isActive; // recipe -> active

  modifier onlyRecipe(address _recipe) {
    require(msg.sender == _recipe, "Monkey: only recipe can call this function");
    _;
  }

  constructor(string memory _uuid, address _human) {
    UUID = keccak256(abi.encodePacked(_uuid));
    human = _human;
  }

  function execute(address _recipe, uint256 _amount, address _token) external onlyRecipe(_recipe) returns (bool) {
    if (!isActive[_recipe]) { return false; }

    IERC20(_token).transfer(_recipe, _amount);

    try IRecipe(_recipe).execute(_amount, _token) {
      emit RecipeExecuted(_recipe, tx.origin);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * TODO: This function call can be moved to Entrypoint eventually
   * 
   * @param _amount: Amount of tokens to deposit
   * @param _token: Address of the token to deposit
   */
  function deposit(uint256 _amount, address _token) external payable {
    if (address(_token) == address(0)) {
      emit FundsDeposited(msg.value, address(0));
      return;
    } 

    require(_amount <= IERC20(_token).balanceOf(msg.sender), "Monkey: not enough balance");
    
    // @todo: This contract must be approved to spend the token!
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    emit FundsDeposited(_amount, _token);
  }

  function withdraw(uint256 _amount, address _token) external {
    if (address(_token) == address(0)) {
      require(_amount <= address(this).balance, "Monkey: not enough balance");
      payable(human).transfer(_amount);
      emit FundsWithdrawn(_amount, address(0));
      return;
    }
    require(_amount <= IERC20(_token).balanceOf(address(this)), "Monkey: not enough balance");
    IERC20(_token).transfer(human, _amount);
    emit FundsWithdrawn(_amount, _token);
  }


  function deactivate(address _recipe) external {
    require(isActive[_recipe], "Monkey: recipe already deactived");
    isActive[_recipe] = false;
    emit RecipePaused(_recipe);
  }

  function activate(address _recipe) external {
    require(!isActive[_recipe], "Monkey: recipe already active");
    isActive[_recipe] = true;
    emit RecipeStarted(_recipe);
  }


  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return this.onERC721Received.selector;
  }

  function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    return interfaceId == type(IMonkey).interfaceId;
  }
}
