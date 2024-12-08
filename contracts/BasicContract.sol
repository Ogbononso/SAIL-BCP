// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract BasicContract{
    uint public storedValue;

    // Function to set the value of storedValue
    function setValue(uint _Value) public {
        storedValue = _Value;
    }

    // Function to get the value of storedValue
    function getValue() public view returns(uint) {
        return storedValue;
    }
}

contract SimpleStorage { 
    uint public storedValue; // Event declaration 
    event ValueChanged(uint newValue); // Function to update stored value and emit the event 
    function setValue(uint _value) public { 
        storedValue = _value; 
        emit ValueChanged(_value); 
    } // Function to retrieve the stored value 
    function getValue() public view returns (uint) { 
        return storedValue; 
    } 
}