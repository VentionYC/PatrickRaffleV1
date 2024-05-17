// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/v0.8/vrf/VRFConsumerBaseV2.sol";

error theEnterFeeisNotEnough();
error theWinnerWithdrawFailed();


contract Raffle is VRFConsumerBaseV2{

    // payable is meant for receive but not send Ether
    uint256 private immutable i_enterRaffleFee;
    address payable[] private s_userAddress;
    //?I don't understand why we are using this since we have the Chainlink can auto call a method with interval
    uint256 private immutable i_interval;
    uint256 private s_timestamp;

   /**
    * the random words required
    * 1. the address of the vrfcoordinator (based on diff network)
    * 2. the gas lane (base on diff network get from chainlink)
    * 3. the subscribtion id
    * +++ the number of request confirmation
    * 4. call back gas limit
    * 5. how many random number you want to have in one request
    */
    //bytes32 private immutable i_vrfCoordinator;
    //address private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    //bytes32 private immutable i_subscribtionId;
    uint64 private immutable i_subscribtionId;
    //Error (9553): Invalid type for argument in function call. Invalid implicit conversion from uint256 to uint16 requested.
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private immutable i_gasLimit;
    //uint256 private immutable i_numWords;
    uint32 private constant NUMWORDS = 1;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    address private s_recentWinner;

    //?How to properly state the Error
    //it should be lower case... error
    //Error (theEnterFeeisNotEnough);

    //uscase of the event remain unknown
    event EnteredUser(address indexed user);

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     */
    constructor(uint256 enterRaffleFee, 
                uint256 interval, 
                bytes32 gasLane,
                address vrfCoordinator,
                uint64 subscribtionId,
                uint32 gasLimit) VRFConsumerBaseV2(vrfCoordinator){
        i_enterRaffleFee = enterRaffleFee;
        i_interval = interval;
        s_timestamp = block.timestamp;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        //i_vrfCoordinator = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
        i_gasLane = gasLane;
        i_subscribtionId = subscribtionId;
        i_gasLimit = gasLimit;

    }

    function enterRaffle() external payable {
        //?what is the unit of the i_enterRaffleFee and msg.value
        //the unit of msg.value is Wei
        //require(msg.value >= i_enterRaffleFee, "the enter fee is not enough");
        if(msg.value < i_enterRaffleFee){
            revert theEnterFeeisNotEnough();
        }else {
            //s_userAddress.push(msg.sender);
            s_userAddress.push(payable(msg.sender));
            emit EnteredUser(msg.sender);
        }
    }

    //1. Get a random number using chainlink VRF
    //2. Used the random number to pick a player
    //3. Be automatically called

    function pickWinner() external {
        if((block.timestamp - s_timestamp)> i_interval){
            s_timestamp = block.timestamp;
        }else{
            revert();
        }
        // This is just done the request, now we have to get the nubmer back
        // So this is the step one, now we have to have the step 2 to get the number back
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, 
            i_subscribtionId, 
            REQUEST_CONFIRMATION, 
            i_gasLimit, 
            NUMWORDS
        );
    }
    //the request ID in the parameter should be the same we have in the above fucntion
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_userAddress.length;
        address payable winner = s_userAddress[indexOfWinner];
        s_recentWinner = winner;

        //.call -> more control over the error handling 
        //.transfer -> encounter en error dufing the transfer, it reverts the transaction entirely
        // to be continue
        (bool success, ) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert theWinnerWithdrawFailed();
        }
    }

    function getEnterRaffleFee() external view returns(uint256){
        return i_enterRaffleFee;
    }


    //why we need to create checkupkeep function?
    //Okay it's because that we have to extend the interface, and this is the function 
    //that we should override
    //let's back to the question that why we still have to count the time whjen we have the chainlink to set the timer for us, because except the time factor, we still have
    // other factor like the balace or other things we should contcer about off the chain, so it's ok to have a seperate limit.
}