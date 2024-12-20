// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DeployLockReleaseTokenPool} from "../DeployLockReleaseTokenPool.s.sol";
import {ClaimAdmin} from "../ClaimAdmin.s.sol";
import {AcceptAdminRole} from "../AcceptAdminRole.s.sol";
import {SetPool} from "../SetPool.s.sol";

contract PrepareOnSourceBlockchain is Script {
    function run() external {
	    console.log("Deploying the token pool on the source blockchain network...");
        (new DeployLockReleaseTokenPool()).run();
    }
}