// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../../src/VaultFactory.sol";
import "../../src/SimpleVault.sol";
import "../../src/OracleVault.sol";
import "../../src/Strategy.sol";
import "../../test/mocks/MockAggregator.sol";

contract CreateVault is Script {
    IVaultFactory constant factory = IVaultFactory(0xbe71be995B1a67EfcebfB1F0E8B89b57c603F9C8);

    function run() public returns (address vault, address strategy) {
        // vm.createSelectFork(stdChains["avalanche"].rpcUrl, 26_179_802);
        vm.createSelectFork(vm.rpcUrl("fuji"));

        ILBPair pair = ILBPair(0x88F36a6B0e37E78d0Fb1d41B07A47BAD3D995453);

        uint256 deployerPrivateKey = vm.envUint("DEPLOY_PRIVATE_KEY");

        /**
         * Start broadcasting the transaction to the network.
         */
        vm.startBroadcast(deployerPrivateKey);

        MockAggregator dataFeedX = new MockAggregator();
        MockAggregator dataFeedY = new MockAggregator();

        (vault, strategy) = factory.createOracleVaultAndDefaultStrategy(pair, dataFeedX, dataFeedY);

        // Poke the contract to make sure we can verify them
        (bool s,) = vault.call(abi.encodeWithSignature("getFactory()"));
        (bool s2,) = strategy.call(abi.encodeWithSignature("getFactory()"));

        vm.stopBroadcast();
        /**
         * Stop broadcasting the transaction to the network.
         */

        require(s && s2, "CreateVault::1");
    }
}
