// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract ArithmeticOperations{
    uint public Addition;
    int public Subtraction;
    uint public Multiplication;
    uint public Division;

    function add(uint a, uint b) public returns(uint){
        // Adds a and b
        Addition = a + b;
        return(Addition);
    }
    function subtract(int a, int b) public returns(int){
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
        require(b != 0, "b should not equal 0");
        Division = a / b;
        return(Division);
    }
}