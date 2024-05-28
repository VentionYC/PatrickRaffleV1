// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;

    struct NetworkConfig {
                uint256 enterRaffleFee;
                uint256 interval;
                bytes32 gasLane;
                address vrfCoordinator;
                uint64 subscribtionId;
                uint32 gasLimit;
    }

    //set some active config
    NetworkConfig public actviceNetWorkConfig;


    //for the mock use?
    //in order to test on the local test net,
    // we at least have to have the gasLane and the vrfcooordinator
    // since these two parameter we get from the other contract, 
    //so we have to create the mocked local contract to get these value.

    //This mocked contract already been done

    constructor (){
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            actviceNetWorkConfig = getSepoliaEthConfig();
            
        }else{
            actviceNetWorkConfig = getOrCreateAnvilEthConfig();
        }
    }

    
    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     * ChainLink_COORDINATOR_URL: https://docs.chain.link/vrf/v2/subscription/supported-networks
     */
    //This is the test net config 
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            enterRaffleFee: 0.01 ether,
            interval: 30, //sec
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            subscribtionId: 0, //Needed for update with the real subId!
            gasLimit: 500000

        });
    }

    //Local net we are using anvil network
    //Test locally need using a mock contract 
    //https://docs.chain.link/vrf/v2/subscription/examples/test-locally
    //function getAnvilEthConfig() public view returns (NetworkConfig memory) {}

    //in order to using the local test net, we have to deploy the mock contract first
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if (actviceNetWorkConfig.vrfCoordinator != address(0)) {
            return actviceNetWorkConfig;
        }

        //constructor of the VRFCoordinatorV2Mock()
        //1. baseFee
        //2. gasPriceLink

        uint96 baseFee = 0.25 ether; //0.25 Link
        uint96 gasPriceLink = 1e9; //1 gwei LINK
        //Deploy mocked contract
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            baseFee, 
            gasPriceLink
            );
        vm.stopBroadcast();

        //uint64 subId = vrfCoordinatorV2Mock.createSubscription();

        NetworkConfig memory netWorkConfig = NetworkConfig({
            enterRaffleFee: 0.01 ether,
            interval: 30, //sec
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,//doesn't matter, leave it like this
            vrfCoordinator: address(vrfCoordinatorV2Mock),
            subscribtionId: 0, //our script will add this????
            gasLimit: 500000

        });


        //vrfCoordinatorV2Mock.addConsumer(subId, address(this));


        return netWorkConfig;
    }
}