// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
contract CreateSub is Script{
    //Doing like this is for the sack of the modularity

    function createSubUsingConfig() public returns (uint256) {
        //Using the helper config
        //openchain.xyz HeX to method
        //Let do the thing that front end will do,
        //which is call the createsubscribtion then add the raffle to the cosumer
        HelperConfig helperConfig = new HelperConfig();
        ( , , , address vrfCoordinator, , , ,uint256 privateKey)= helperConfig.actviceNetWorkConfig();
        return createSubscription(vrfCoordinator, privateKey);
    }

    function createSubscription(address vrfCoordinator, uint256 privateKey) public returns(uint256) {
        console.log("the block id is " , block.chainid);
        uint256 subId;
        vm.startBroadcast(privateKey);
            subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("your sub id is ", subId);
        return subId;
        //return vrfCoordinator.createSubscription();
    }
    

    
    //run() return the sub ID
    function run() external returns (uint256){
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
                uint256 subscribtionId, ,
                address link,
                uint256 privateKey  )= helperConfig.actviceNetWorkConfig();

        fundSubcription(vrfCoordinator, subscribtionId, link, privateKey);

    }

    function fundSubcription(address vrfCoordinator, 
                            uint256 subId, 
                            address linktoken,
                            uint256 privateKey) public{
        console.log("Funding subid " , subId);
        console.log("VRF " , vrfCoordinator);
        console.log("on Chain ID " , block.chainid);
        if (block.chainid ==  LOCAL_CHAIN_ID) {
            vm.startBroadcast(privateKey);
            //Between vm.startBroadcast and vm.stopBroadcast, 
            //you should deploy your contracts and make any necessary transactions.
            //fundSubscription didn't exsit on the real contract
            //2.0
            //VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            //2.5
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();  
        }else{
            //do the real transfer here
            //This is on the test net?
            vm.startBroadcast(privateKey);
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
        //get most recent deploy contract
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle", 
            block.chainid);

        addCustomerUsingConfig(raffle);
    }

    function addCustomerUsingConfig(address owner) public{

        HelperConfig helperConfig = new HelperConfig();
        ( , , ,address vrfCoordinator 
            ,uint256 subscribtionId , , 
            ,uint256 privateKey )= helperConfig.actviceNetWorkConfig();

        addCustomer(vrfCoordinator, subscribtionId, owner, privateKey);
    }

    function addCustomer(address vrfCoordinator,
                         uint256 subId,
                         address contractAddress,
                         uint256 privateKey) public{
                            vm.startBroadcast(privateKey);
                            //2.0
                            //VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, contractAddress);
                            //2.5
                            //VRFCoordinatorV2_5Mock is SubscriptionAPI which have the addconcumer function
                            VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, contractAddress);
                            vm.stopBroadcast();
                         }
}