// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";




contract Raffle is AutomationCompatibleInterface, VRFConsumerBaseV2Plus {
//the cumtom error should be inside in order for other contract to access or say test
    error theEnterFeeisNotEnough();
    error theWinnerWithdrawFailed();
error Raffle_UpkeepNotNeeded(
    uint256 contractBalance,
    uint256 userCount
);
error Raffle_RaffleNotOpen();

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    // hello there forget to code?
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
   // IVRFCoordinatorV2Plus private s_vrfCoordinator;

    //Basic enter fee, user address(last winner record), between time and start time
    uint256 private immutable i_enterRaffleFee;
    address payable[] private s_userAddress;
    uint256 private immutable i_interval;
    uint256 private s_timestamp;
    address private s_recentWinner;

   /**
    * the random words required
    * 1. the address of the vrfcoordinator (based on diff network)
    * 2. the gas lane (base on diff network get from chainlink)
    * 3. the subscribtion id
    * +++ the number of request confirmation
    * 4. call back gas limit
    * 5. how many random number you want to have in one request
    */
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscribtionId;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private immutable i_gasLimit;
    uint32 private constant NUMWORDS = 1;

    RaffleState private s_raffleState;

    event EnteredUser(address indexed user);
    event RequestRaffleWinner(uint256 indexed winner);

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     */
    constructor(uint256 enterRaffleFee, 
                uint256 interval, 
                bytes32 gasLane,
                address vrfCoordinator,
                uint256 subscribtionId,
                uint32 gasLimit) VRFConsumerBaseV2Plus(vrfCoordinator){
        i_enterRaffleFee = enterRaffleFee;
        i_interval = interval;
        s_timestamp = block.timestamp;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        //i_vrfCoordinator = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
        i_gasLane = gasLane;
        i_subscribtionId = subscribtionId;
        i_gasLimit = gasLimit;
        

        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        //?what is the unit of the i_enterRaffleFee and msg.value
        //the unit of msg.value is Wei
        //require(msg.value >= i_enterRaffleFee, "the enter fee is not enough");
        if(msg.value < i_enterRaffleFee){
            revert theEnterFeeisNotEnough();
        }else if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }else{
            //s_userAddress.push(msg.sender);
            s_userAddress.push(payable(msg.sender));
            emit EnteredUser(msg.sender);
        }
    }

    //1. Get a random number using chainlink VRF
    //2. Used the random number to pick a player
    //3. Be automatically called

    function pickWinner() internal returns (uint256 requestId) {
        //into the performupkeep function
        // if((block.timestamp - s_timestamp)> i_interval){
        //     s_timestamp = block.timestamp;
        // }else{
        //     revert();
        // }
        // This is just done the request, now we have to get the nubmer back
        // So this is the step one, now we have to have the step 2 to get the number back
        // requestId = i_vrfCoordinator.requestRandomWords(
        //     i_gasLane, 
        //     i_subscribtionId, 
        //     REQUEST_CONFIRMATION, 
        //     i_gasLimit, 
        //     NUMWORDS
        // );
        
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscribtionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_gasLimit,
                numWords: NUMWORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false
                    })
                )
            })
        );
    }
    //the request ID in the parameter should be the same we have in the above fucntion
    function fulfillRandomWords(uint256 /*requestId*/, uint256[] calldata randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_userAddress.length;
        address payable winner = s_userAddress[indexOfWinner];
        s_recentWinner = winner;
        s_timestamp = block.timestamp;

        //.call -> more control over the error handling 
        //.transfer -> encounter en error dufing the transfer, it reverts the transaction entirely
        // to be continue
        (bool success, ) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert theWinnerWithdrawFailed();
        }else{
            s_raffleState = RaffleState.OPEN;
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

    function checkUpkeep(
        bytes memory /*checkData*/
        ) public view override returns (
            bool upkeepNeeded, 
            bytes memory /*performData*/){
                bool isOpen = RaffleState.OPEN == s_raffleState;

                bool timePassed = ((block.timestamp - s_timestamp) > i_interval);
                bool hasPlayers = s_userAddress.length > 0;
                bool hasBalance = address(this).balance >0;
                upkeepNeeded = (timePassed && hasBalance && hasPlayers && isOpen);
                return (upkeepNeeded, "0x0");

    }

    function performUpkeep(bytes memory /*performData*/) external  override{
        (bool upkeepNeeded, )  =  checkUpkeep("");
        if (!upkeepNeeded) {
            //degub purpose
            revert Raffle_UpkeepNotNeeded(
                address(this).balance,
                s_userAddress.length
            );
        }

        s_raffleState = RaffleState.CALCULATING;
        //uint256 requestId = pickWinner();
        //the request ID is already emit by the requestrandomwords, this is just for the test showing

            uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscribtionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_gasLimit,
                numWords: NUMWORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false
                    })
                )
            })
        );
        emit RequestRaffleWinner(requestId);


    }

    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    } 

    function getUserList() external view returns(address payable[] memory){
        return s_userAddress;
    }

    function getLengthOfTheUser() external view returns(uint256) {
        return s_userAddress.length;
    }

    function getLastTimeStamp() external view returns(uint256){
            return s_timestamp;
    }

    function getRecentWinner() external view returns(address){
        return s_recentWinner;
    }
        
}