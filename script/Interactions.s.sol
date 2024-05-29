// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
contract CreateSub is Script{
    //Doing like this is for the sack of the modularity

    function createSubUsingConfig() public returns (uint64) {
        //Using the helper config
        //openchain.xyz HeX to method
        //Let do the thing that front end will do,
        //which is call the createsubscribtion then add the raffle to the cosumer
        HelperConfig helperConfig = new HelperConfig();
        ( , , , address vrfCoordinator, , , )= helperConfig.actviceNetWorkConfig();
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
    uint256 private constant LOCAL_CHAIN_ID   = 31337;
    function fundSubscriptionUsingConfig() public {
        //need sub id
        //need vrf coordiantor v2 address
        //Link address -> Let's add the link token into our Helper config

        HelperConfig helperConfig = new HelperConfig();
        ( , , , address vrfCoordinator, 
                uint64 subscribtionId, ,
                address link )= helperConfig.actviceNetWorkConfig();

        fundSubcription(vrfCoordinator, subscribtionId, link);

    }

    function fundSubcription(address vrfCoordinator, 
                            uint64 subId, 
                            address linktoken) public{
        console.log("Funding subid " , subId);
        console.log("VRF " , vrfCoordinator);
        console.log("on Chain ID " , block.chainid);
        if (block.chainid ==  LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            //Between vm.startBroadcast and vm.stopBroadcast, 
            //you should deploy your contracts and make any necessary transactions.
            //fundSubscription didn't exsit on the real contract
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();  
        }else{
            //do the real transfer here
            //This is on the test net?
            vm.startBroadcast();
           //don't worry about what this is doing for now
            LinkToken(linktoken).transferAndCall(vrfCoordinator, 
                                                FUND_AMOUNT, 
                                                abi.encode(subId));


            vm.stopBroadcast();
        }

    }
    
    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddCustomer is Script {
    function run() external {
        
    }
}