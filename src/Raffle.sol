// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
error theEnterFeeisNotEnough();


contract Raffle {
    // //uint256 private s_ticketPrice;
    // uint256 private immutable i_ticketPrice;
    // //external is more gas effixiotn than public
    // uint256 private immutable i_interval;
    // address private immutable i_vrfCoordinator;


    // constructor(uint256 ticketPrice, uint256 interval, address vrfCoordinator) {  
    //     //s_ticketPrice = ticketPrice; 
    //     i_ticketPrice = ticketPrice;
    //     i_interval = interval;
    //     i_vrfCoordinator = vrfCoordinator;
    // }
    // function buyTheTicket() external payable {
        
    // }

    // function pickWinner()  public returns (uint256) {
        
    // }

    // Every method have to has visibility
    // function getTicketPrice() public view returns (uint256){
    //     return i_ticketPrice;
    // }

    //custom error for not meet the value of the ticket
    //Better name the error start with the contract
    //todo 

    // payable is meant for receive but not send Ether
    uint256 private immutable i_enterRaffleFee;
    address payable[] private s_userAddress;
    //?I don't understand why we are using this since we have the Chainlink can auto call a method with interval
    uint256 private immutable i_interval;
    uint256 private s_timestamp;

    //?How to properly state the Error
    //it should be lower case... error
    //Error (theEnterFeeisNotEnough);

    //uscase of the event remain unknown
    event EnteredUser(address indexed user);

    constructor(uint256 enterRaffleFee, uint256 interval){
        i_enterRaffleFee = enterRaffleFee;
        i_interval = interval;
        s_timestamp = block.timestamp;
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
    }

    function getEnterRaffleFee() external view returns(uint256){
        return i_enterRaffleFee;
    }
}