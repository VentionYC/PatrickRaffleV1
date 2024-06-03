// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/Deploy.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helper;
    uint256 enterRaffleFee;
    uint256 interval;
    bytes32 gasLane;
    address vrfCoordinator;
    uint64 subscribtionId;
    uint32 gasLimit;
    address link;
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_BALANCE = 10 ether;

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee} ();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

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
                 gasLimit,
                 link
        )= helper.actviceNetWorkConfig();
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

   ////////////////////////////////// Enter the raffle test //////////////////
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

    //you can try the blow test, it failed but I still don't know the reason
    //todo

//    function testRaffleEnterState() public returns(bool){
//         vm.prank(PLAYER);
//         //first we have to meke sure that enough time have passed
//         //the foundry cheat code\
//         //vm.warp() set the blo k time
//         //vm.roll set the block number     

//         vm.warp(block.timestamp + interval + 1);
//         vm.roll(block.number +1);

//         bytes memory performData = "";
//         raffle.performUpkeep(performData);
//         vm.expectRevert(Raffle.Raffle_RaffleNotOpen.selector);

//         raffle.enterRaffle{value: enterRaffleFee}();
//         //still need to use the funtion in the raffle which have 
//         //the ability to set the raffle statue to calculating.

//         //so the next action should be how we can call the preform upkeep function
//         //in order to real test the status of the opening, we first have to make sure
//         //that the checkUpkeep is passed in the code.c
//    }

    function testRaffleEnterState() public{
        //first we have to simuliate the real situation
        //create a player and enter the raffle
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee} ();
        //and let's assume enough time have passed
        vm.warp(block.timestamp + interval + 1);
        //this step is not nessary to do but ...
        vm.roll(block.number + 1);

        //now let call the perform upkeep, 
        //the condition should be enought to pass the checkupkeep()
        raffle.performUpkeep("");
        //then the next player will be enter
        //prank will create the new player address
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_RaffleNotOpen.selector);
        raffle.enterRaffle{value: enterRaffleFee} ();



    }

    function testIncreaseUserRecordWhenEntered() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee}();
        address payable[] memory user = raffle.getUserList();
        assert (user[0] == PLAYER);

    }

    function testEnterUserEvent() public {
        vm.prank(PLAYER);
        //1.leave the parameter empty means check it all?
        //https://book.getfoundry.sh/cheatcodes/expect-emit
        vm.expectEmit();
        //2.Emit the event we are supposed to see during trhe next call(I mean the reall funciton call)
        //RealClassName.RealEventName
        emit Raffle.EnteredUser(address(PLAYER));
        //3.Let's call the event, 
        //instance of class.function
        //have to have enought fund, this is a payable method
        raffle.enterRaffle{value: enterRaffleFee}();
    }

    /////////////////////////////////////// Checkupkeep test/////////
    //1. it should return false if the address have no balance
    function testCheckUpkeepReturnsFalseIfTheAddressHaveNoBalance() public  {
        //Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number +1);

        //Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        //assert inside is ture, then pass
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnFalseIfRaffleNotOpen() public {
        //Arrange
        //enough time have passed
        //the address have enough balance
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number +1);
        raffle.performUpkeep("");

        //Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        //assert inside is ture, then pass
        assert(!upkeepNeeded);  
    }

    function testCheckUpkeepReturnFalseIfNotEnoughTime() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee} ();
        vm.warp(block.timestamp + interval - 1);
        vm.roll(block.number + 1);
        
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnTrueIfParameterAreGood() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee} ();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number +1);

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(upkeepNeeded);
    }


    ////////////////////
    // performUpkeep //
    ///////////////////

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public {
        // Arrange, let's meet the condition that makes the checkUpkeep return true
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enterRaffleFee} ();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number +1);

        //Act /assert
        //That's why insert the upkeepcheck in the perfromUpkeep in Raffle is for
        // the test debuging purpose, is the funciton didn't revert, then it will
        // consider as pass
        raffle.performUpkeep("");

    }

    function testPerformUpkeepRevertIfCheckUpkeepIsFalse() public {
        //vm.expectRevert(Raffle.Raffle_UpkeepNotNeeded.selector);
        uint256 currentBalance = 0;
        uint256 numPlayer = 0;
        //There is no fucking raffle state add in in my code
        //uint256 raffleState = 0;

        vm.expectRevert (abi.encodeWithSelector(
                             Raffle.Raffle_UpkeepNotNeeded.selector,
                             currentBalance,
                             numPlayer
        ));

        raffle.performUpkeep("");
        
    }

    //Since that the smart contract itself can't asscess the emitted event
    //What if I need to test using the output of an event?
    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredAndTimePassed{
            //Act
            vm.recordLogs();
            raffle.performUpkeep("");
            Vm.Log[] memory entries = vm.getRecordedLogs();
            //entries[1] -> the event we emit
            //topic[0] -> the entire EVENT, then is the real topic
            bytes32 requestId = entries[1].topics[1];
            //entries[0] -> VRFCoordinatorV2Mock ->RandomWordsRequested
            //bytes32 requestId = entries[0].topics[2];

            Raffle.RaffleState rState = raffle.getRaffleState();

            assert(uint256(requestId) >0);
            assert(uint256(rState) > 0);
    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep() public raffleEnteredAndTimePassed{
        //Arrange
        // in the fulfillRandomWordsWithOverride in Mock
        // if there is no subID, then it will review below
        vm.expectRevert("nonexistent request");
        
        //VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(0, address(raffle));
        //Since there is no real subID, so no matter what the subID here is
        //it all should revert
        //So we should test all the nubmers
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(11, address(raffle));
    }

    //so let's try to add the parameter to a test
    //[PASS] testFullfillRandomWordsCanOnlyBeCalledAfterPerfomUpkeepWithPara(uint256) (runs: 257, μ: 80549, ~: 80549)
    function testFullfillRandomWordsCanOnlyBeCalledAfterPerfomUpkeepWithPara(uint256 randomRequest)
                public raffleEnteredAndTimePassed {
                    vm.expectRevert("nonexistent request");
                    //pretend to be the fake VRF can only work in local Chain
                    //in test net or main net
                    //Only the real VRF can call the fulfillRandomwords
                    VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequest, address(raffle));
    }

    ///////////////////////
    //// ONE BIG TEST //// 
    /////////////////////

    function testFulfillRandomWordsPicksAWinnerResetsAndSendsMoney() 
            public raffleEnteredAndTimePassed {
                // we will pretend to be the chianlink VRF to 
                //call the random number

                //Arrange

                /////////////////////////////////
                //More player enter the raffle//
                ///////////////////////////////
                uint256 additionalEntrants = 5;
                uint256 startingIndex = 1;

                for(uint256 i = startingIndex; i < startingIndex + additionalEntrants; i++){
                    //this will generate the address base on the number "i"
                    address player = address(uint160(i));
                    //PRANK + deal = hoax
                    hoax(player, STARTING_BALANCE);
                    //more player with money is added, let's let them ENTER
                    raffle.enterRaffle{value: enterRaffleFee}();
                }
                //before the perform upkeep, the winner price should be
                uint256 price = enterRaffleFee * (additionalEntrants +1);


                /////////////////////////////////////////////
                //Pretend to be chainlink VRF to get number-> pick the winner/
                ///////////////////////////////////////////
                //1. we have to have the request ID from the log
                vm.recordLogs();
                raffle.performUpkeep("");
                Vm.Log[] memory entries = vm.getRecordedLogs();
                bytes32 requestId = entries[1].topics[1];
                uint256 previousLastTimestamp = raffle.getLastTimeStamp();
                // pretend to be chainlink vrf to get random number & pick winner
                VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));
                console.log("timestamp 1 ", previousLastTimestamp);
                //assert 
                assert(uint256(raffle.getRaffleState()) == 0);
                assert(raffle.getRecentWinner() != address(0));
                assert(raffle.getLengthOfTheUser() != 0);
                //
                console.log("timestamp 2 ", block.timestamp);

                assert(previousLastTimestamp < raffle.getLastTimeStamp());

                //make sure it really gets send some money
                assert(address(raffle.getRecentWinner()).balance == (STARTING_BALANCE - enterRaffleFee + price));
                
                

    }
    

}