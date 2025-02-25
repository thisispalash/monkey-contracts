// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Monkey} from "./Monkey.sol";
import {IMonkeyFactory} from "./IMonkeyFactory.sol";

contract MonkeyFactory is IMonkeyFactory {
    
  function createMonkey(address _human, string memory _uuid) external returns (address) {
    Monkey monkey = new Monkey(_uuid, _human);
    emit SpawnMonkey(address(monkey), _human, _uuid);
    return address(monkey);
  }
}
