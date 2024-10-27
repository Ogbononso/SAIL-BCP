// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract ArithmeticOperations{
    uint public Addition;
    uint public Subtraction;
    uint public Multiplication;
    uint public Division;

    function add(uint a, uint b) public returns(uint){
        // Adds a and b
        Addition = a + b;
        return(Addition);
    }
    function subtract(uint a, uint b) public returns(uint){
        // Subtracts a from b
        Subtraction = a - b;
        return(Subtraction);
    }
    function multiply(uint a, uint b) public returns(uint){
        // Multiplies a by b
        Multiplication = a * b;
        return(Multiplication);
    }
    function divide(uint a, uint b) public returns(uint){
        // Divides a by b
        Division = a / b;
        return(Division);
    }
}