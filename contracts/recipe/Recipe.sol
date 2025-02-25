// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import {IRecipe} from "./IRecipe.sol";

abstract contract Recipe is IRecipe, ERC721Upgradeable {

  uint24 public constant COMPENSATION_FEE = 5000; // hundredths of basis points, max 2.5% or 25000; currently 0.5%

  string public identifier;
  address public creator;

  uint256 public tokenId;
  mapping(address => bool) public isCopying;

  function __Recipe_init(string memory _identifier, address _creator) internal {
    identifier = _identifier;
    creator = _creator;
    tokenId = 0;
    safeMint(creator); // 0-th token minted is the creator's
  }

  function copy(address _monkey) external {
    safeMint(_monkey);
  }

  function mint(address to) public pure {
    revert("Recipe: minting is not allowed");
  }

  function safeMint(address to) public {
    _safeMint(to, tokenId);
    isCopying[to] = true;
    emit MonkeyAdded(to, tokenId);
    tokenId++;
  }

  function buy(uint256 _amountIn) internal virtual returns (uint256);
  function sell(uint256 _amountIn) internal virtual returns (uint256);
  function royalties(uint256 _amountOut, address _tokenOut) internal virtual returns (uint256);
  function compensation(uint256 _amountOut, address _tokenOut) internal virtual returns (uint256);


  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
    return interfaceId == type(ERC721Upgradeable).interfaceId 
      || interfaceId == type(IRecipe).interfaceId
      || super.supportsInterface(interfaceId);
  }

}
