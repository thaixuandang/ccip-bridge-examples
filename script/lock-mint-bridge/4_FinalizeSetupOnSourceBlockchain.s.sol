// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {ApplyChainUpdates} from "../ApplyChainUpdates.s.sol";
import {HelperUtils} from "../utils/HelperUtils.s.sol"; // Utility functions for JSON parsing and chain info
import {HelperConfig} from "../HelperConfig.s.sol"; // Network configuration helper
import {BurnMintERC677} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import {TokenAdminRegistry} from "@chainlink/contracts-ccip/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {BurnMintTokenPool} from "@chainlink/contracts-ccip/src/v0.8/ccip/pools/BurnMintTokenPool.sol";

contract FinalizeSetupOnSourceBlockchain is Script {
    function run() external {
        console.log("Apply chain updates on the token pool on the source blockchain network...");
        (new ApplyChainUpdates()).run();

        // Get the chain name based on the current chain ID
        string memory chainName = HelperUtils.getChainName(block.chainid);

        // Construct paths to the JSON files containing deployed token and pool addresses
        string memory root = vm.projectRoot();
        string memory configPath = string.concat(root, "/script/config.json");
        string memory deployedPoolPath = string.concat(root, "/script/output/deployedTokenPool_", chainName, ".json");

        // Extract the token admin address (multisig) from the config.json file
        address admin = HelperUtils.getAddressFromJson(vm, configPath, ".BnMToken.admin");

        // Extract the deployed token and pool addresses from the JSON files
        address poolAddress =
            HelperUtils.getAddressFromJson(vm, deployedPoolPath, string.concat(".deployedTokenPool_", chainName));

        require(admin != address(0), "Invalid admin address");
        require(poolAddress != address(0), "Invalid pool address");

        // Transfer token pool ownership to the multisig wallet. The multisig wallet needs to call acceptOwnership() to accept the ownership.
        vm.broadcast();
        BurnMintTokenPool(poolAddress).transferOwnership(admin);
    }
} 