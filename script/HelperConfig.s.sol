// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {


    //We will need vrfCoordinator right?
    struct NetworkConfig {
                uint256 enterRaffleFee;
                uint256 interval;
                bytes32 gasLane;
                address vrfCoordinator;
                uint64 subscribtionId;
                uint32 gasLimit;
    }
}