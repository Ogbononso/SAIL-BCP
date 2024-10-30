//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Define a contract named EvenOddChecker
contract EvenOddChecker{

// Function to check if a given number is even or odd
// Returns a string indicating if it is "Even" or "Odd"
    function checkEvenOdd(uint Number) public pure returns(string memory) {

        // Check if the number is even using a modulus operator
        // A number is even if when divided by 2 equals to 0
        if(Number % 2 == 0){

        // If the condition is true return "Even"
            return ("Even");
        }else{
        // If the condition is false return "Odd"    
            return ("Odd");
        }
    }
}
