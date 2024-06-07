// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    address public constant SEPOLIA_VRF_2_5_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public constant SEPOLIA_VRF_2_5_GAS_LANE = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public constant ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct NetworkConfig {
                uint256 enterRaffleFee;
                uint256 interval;
                bytes32 gasLane;
                address vrfCoordinator;
                uint256 subscribtionId;
                uint32 gasLimit;
                address link;
                uint256 privateKey;

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
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            enterRaffleFee: 0.01 ether,
            interval: 30, //sec
            gasLane: SEPOLIA_VRF_2_5_GAS_LANE,
            vrfCoordinator: SEPOLIA_VRF_2_5_COORDINATOR,
            subscribtionId: 17567876347256142007997470531990983328881883535997831679022352995396763935343, //Needed for update with the real subId!
            gasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            privateKey: vm.envUint("PRIVATE_KEY")
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
        LinkToken linkToken  = new LinkToken();
        vm.stopBroadcast();

        //uint64 subId = vrfCoordinatorV2Mock.createSubscription();

        NetworkConfig memory netWorkConfig = NetworkConfig({
            enterRaffleFee: 0.01 ether,
            interval: 30, //sec
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,//doesn't matter, leave it like this
            vrfCoordinator: address(vrfCoordinatorV2Mock),
            subscribtionId: 0, //our script will add this????
            gasLimit: 500000,
            link: address(linkToken),//we need to deploy a mocked link token?
            //Chainlink contract verion link?
            privateKey: ANVIL_PRIVATE_KEY

        });


        //vrfCoordinatorV2Mock.addConsumer(subId, address(this));


        return netWorkConfig;
    }
}