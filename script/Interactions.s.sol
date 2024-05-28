// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/v0.8/mocks/VRFCoordinatorV2Mock.sol";
contract CreateSub is Script{
    //Doing like this is for the sack of the modularity
    
    function createSubUsingConfig() public returns (uint64) {
        //Using the helper config
        //openchain.xyz HeX to method
        //Let do the thing that front end will do,
        //which is call the createsubscribtion then add the raffle to the cosumer
        HelperConfig helperConfig = new HelperConfig();
        ( , , , address vrfCoordinator, , )= helperConfig.actviceNetWorkConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns(uint64) {
        console.log("the block id is " , block.chainid);
        uint64 subId;
        vm.startBroadcast();
            subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("your sub id is ", subId);
        return subId;
        //return vrfCoordinator.createSubscription();
    }
    

    
    //run() return the sub ID
    function run() external returns (uint64){
        return createSubUsingConfig();
    }
}

contract FundSub is Script{
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        //need sub id
        //need vrf coordiantor v2 address
        //Link address7

    }
    
    function run() external {
        fundSubscriptionUsingConfig();
    }
}