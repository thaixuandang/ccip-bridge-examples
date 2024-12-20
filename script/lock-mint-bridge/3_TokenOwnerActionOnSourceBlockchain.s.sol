// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {ClaimAdmin} from "../ClaimAdmin.s.sol";
import {AcceptAdminRole} from "../AcceptAdminRole.s.sol";
import {SetPool} from "../SetPool.s.sol";
import {HelperUtils} from "../utils/HelperUtils.s.sol"; // Utility functions for JSON parsing and chain info
import {HelperConfig} from "../HelperConfig.s.sol"; // Network configuration helper
import {TokenAdminRegistry} from "@chainlink/contracts-ccip/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {BurnMintTokenPool} from "@chainlink/contracts-ccip/src/v0.8/ccip/pools/BurnMintTokenPool.sol";

contract TokenOwnerActionOnSourceBlockchain is Script {
    function run() external {
	    console.log("Claim admin role of the token on the source blockchain network...");
        (new ClaimAdmin()).run();

	    console.log("Accept admin role of the token on the source blockchain network...");
        (new AcceptAdminRole()).run();

        console.log("Set token pool on the source blockchain network...");
        (new SetPool()).run();

        // Get the chain name based on the current chain ID
        string memory chainName = HelperUtils.getChainName(block.chainid);

        // Construct paths to the JSON files containing deployed token and pool addresses
        string memory root = vm.projectRoot();
        string memory configPath = string.concat(root, "/script/config.json");
        string memory deployedTokenPath = string.concat(root, "/script/output/deployedToken_", chainName, ".json");
        string memory deployedPoolPath = string.concat(root, "/script/output/deployedTokenPool_", chainName, ".json");

        // Extract the token admin address (multisig) from the config.json file
        address admin = HelperUtils.getAddressFromJson(vm, configPath, ".BnMToken.admin");

        // Extract the deployed token and pool addresses from the JSON files
        address tokenAddress =
            HelperUtils.getAddressFromJson(vm, deployedTokenPath, string.concat(".deployedToken_", chainName));
        address poolAddress =
            HelperUtils.getAddressFromJson(vm, deployedPoolPath, string.concat(".deployedTokenPool_", chainName));

        // Fetch the network configuration to get the TokenAdminRegistry address
        HelperConfig helperConfig = new HelperConfig();
        (,,, address tokenAdminRegistry,,,,) = helperConfig.activeNetworkConfig();

        require(admin != address(0), "Invalid admin address");
        require(tokenAddress != address(0), "Invalid token address");
        require(poolAddress != address(0), "Invalid pool address");
        require(tokenAdminRegistry != address(0), "TokenAdminRegistry is not defined for this network");

        // Transfer CCIP token admin role to the multisig wallet. The multisig wallet needs to call acceptAdmin() to accept the admin role.
        vm.broadcast();
        TokenAdminRegistry(tokenAdminRegistry).transferAdminRole(tokenAddress, admin);
    }
}