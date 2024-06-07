// SPDX-License-Identifier: MIT
///Users/ventionyoung/Web3Project/foundry-f23/Web3/lib/forge-std/src/Script.sol
pragma solidity ^0.8.18; 
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSub} from "./Interactions.s.sol";
import {FundSub} from "./Interactions.s.sol";
import {AddCustomer} from "./Interactions.s.sol";

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
                uint256 subscribtionId,
                uint32 gasLimit,
                address link,
                uint256 privateKey
        )= helperConfig.actviceNetWorkConfig();

        //if the subID passed from helper is 0, we have to create the sub ID in the script
        if(subscribtionId == 0){
            //let's cratet the sub id here
            CreateSub createSub = new CreateSub();
            FundSub fundSub = new FundSub();
            
            subscribtionId = createSub.createSubscription(vrfCoordinator);
            // Now we have to fund it!!!
            // let's crate another contract in interaction ?
            fundSub.fundSubcription(vrfCoordinator,subscribtionId,link,privateKey);

            //now we have to add the customer
            //addConsumer.addCustomerUsingConfig(vrfCoordinator,)
    
        }

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
        //We add the consumer in the last steop
        AddCustomer addConsumer = new AddCustomer();
        addConsumer.addCustomer(vrfCoordinator,subscribtionId, address(raffle),privateKey);

        return (raffle, helperConfig);
    }
}