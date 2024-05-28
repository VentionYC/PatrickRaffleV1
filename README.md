
# Solidity formate
 ## Payable modifier
    * It's meant for receive but not send Ether, address.. function...
 ## Layout of Contract:
 1. version
 2. imports
 3. errors
 4. interfaces, libraries, contracts
 5. Type declarations
 6. State variables
 7. Events
 8. Modifiers
 9. Functions

 ## Layout of Functions:
 1. constructor
 2. receive function (if exists)
 3. fallback function (if exists)
 4. external
 5. public
 6. internal
 7. private
 8. view & pure functions

# Foundry
 ## Function
    * makeAddr
 ## Cheatcode
  ### Give me some money!
    * vm.deal(address, uint256)