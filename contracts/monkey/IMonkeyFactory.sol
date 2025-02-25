// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

interface IMonkeyFactory {

  event SpawnMonkey(address indexed monkey, address indexed human, string uuid);

  function createMonkey(address _human, string memory _uuid) external returns (address);
}
