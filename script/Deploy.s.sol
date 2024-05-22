// SPDX-License-Identifier: MIT
///Users/ventionyoung/Web3Project/foundry-f23/Web3/lib/forge-std/src/Script.sol
pragma solidity ^0.8.18; 
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    //we need to create a run function
    //the run() funciton like the setup() function in the test, both the name should not be changed

        // constructor(uint256 enterRaffleFee, 
        //         uint256 interval, 
        //         bytes32 gasLane,
        //         address vrfCoordinator,
        //         uint64 subscribtionId,
        //         uint32 gasLimit) VRFConsumerBaseV2(vrfCoordinator

        // some of the raffle input parameter above in the constructor, will depened on what chain we are using, 
        // so we can create Helperconfig to help with no matter what chain we are deploy to, we are good to go
    function run() external returns (Raffle,HelperConfig) {
        //Based on the active Network, can have diff config
        HelperConfig helperConfig = new HelperConfig();
        (
                uint256 enterRaffleFee,
                uint256 interval,
                bytes32 gasLane,
                address vrfCoordinator,
                uint64 subscribtionId,
                uint32 gasLimit
        )= helperConfig.actviceNetWorkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            enterRaffleFee,
            interval,
            gasLane,
            vrfCoordinator,
            subscribtionId,
            gasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}