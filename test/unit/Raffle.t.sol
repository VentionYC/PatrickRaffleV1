// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/Deploy.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {

        //need some fake user to interact with raffle
        //Description
        // Creates an address derived from the provided name.

        // A label is created for the derived address with the provided name used as the label value.
    Raffle raffle;
    HelperConfig helper;
    uint256 enterRaffleFee;
    uint256 interval;
    bytes32 gasLane;
    address vrfCoordinator;
    uint64 subscribtionId;
    uint32 gasLimit;
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //Using the script to deploy
        DeployRaffle deployer = new DeployRaffle();
        //helper = new HelperConfig();
        (raffle, helper) = deployer.run();
        (
                 enterRaffleFee,
                 interval,
                 gasLane,
                 vrfCoordinator,
                 subscribtionId,
                 gasLimit
        )= helper.actviceNetWorkConfig();

        //give palyer some money
        vm.deal(PLAYER, STARTING_BALANCE);
    }

/*
Error (2271): Built-in binary operator == cannot be applied to types uint256 and function () view external returns (uint256).
  --> test/unit/Raffle.t.sol:48:12:
   |
48 |         if(block.chainid == helper.SEPOLIA_CHAIN_ID) {
    function testRaffleInit() public {
        //my thought: this should check the local var's value in this test match
        //match  what?
        //first we have to check what network are we in right?
        //then we can check the value base on the network we are in

        if(block.chainid == helper.SEPOLIA_CHAIN_ID) {

        }else{

        }
    }

    */

   //completely not what I thought, so let's test the raffle state is open or not after its init

   function testRaffleStateisOpenWhenInit() public view{
    //That's why we should have a getter function in the contract
    //raffle.s_raffleState, raffle.RaffleState.OPEN

    //assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);

    //Enum Declaration
//When you declare an enum within a contract, 
// its visibility depends on whether the contract itself is accessible.
//  If another contract has access to the contract containing the enum, 
//  it can use the enum type directly.
// assert is in solidity, assertEq is in foundry.

    assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));

   }

   ////////////////////////////////// START OF THE TEST //////////////////
   //Arrange//Act//Assert
    // Arrange: in this step, you set up the initial state and prepare everything 
    //needded for the test, this might include deploying contracts, 
    //setting initial value and preparing any reuired data

    //Act: This is hwerer you perform the action that you wnat to test.
    // this usually involves calling function ont you contract.

    //Assert: Finally, you check that the expedted results have occurred, 
    //You verify that the contract's state has changed as expected, 
    //events have been emitted, or the correct value have been returneedd.

   /////////////////Enter Raffle Test/////////////////////////////////////
   //my thought is that we should test the enter fee and state seperately
   //function testRaffleMiniFee() public returns(bool){}

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(PLAYER);
        //set the NEXT call to be made from a specified address
        //expectRevert Error message inside ()
        // expectRevert is used to set an expectation that 
        //the next function call should revert with a specific error
        vm.expectRevert(Raffle.theEnterFeeisNotEnough.selector);
        //raffle.enterRaffle{value: 3 ether}();
        raffle.enterRaffle();
        
    }

//    function testRaffleEnterState() public returns(bool){

//    }


    function testIncreaseUserRecordWhenEntered() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee}();
        address payable[] memory user = raffle.getUserList();
        assert (user[0] == PLAYER);

    }


}