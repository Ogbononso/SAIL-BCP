// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableContract {
    // Mapping to store balances of users
    mapping(address => uint256) public balances;

    // Owner address for access control
    address public owner;

    constructor() {
        owner = msg.sender; // Set the deployer as the owner
    }

    // Function to deposit Ether into the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some Ether");
        balances[msg.sender] += msg.value; // Vulnerable to integer overflow in older versions of Solidity
    }

    // Function to withdraw funds
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // Vulnerability: Reentrancy attack vector
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount; // Update balance after sending Ether
    }

    // Admin-only function to reset user balances
    function resetBalance(address _user) public {
        // Vulnerability: No proper access control
        require(msg.sender == owner, "Only owner can reset balances");
        balances[_user] = 0;
    }

    // Function to update the owner (bad practice for access control)
    function changeOwner(address _newOwner) public {
        // Vulnerability: Anyone can change the owner
        owner = _newOwner;
    }
}

import "@openzeppelin/contracts/access/Ownable.sol";

contract SecureContract is Ownable {
    mapping(address => uint256) public balances;
    bool private locked;

    constructor() {
        locked = false;
    }

    modifier reentrancyGuard() {
        require(!locked, "Reentrancy detected!");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        require(msg.value > 0, "Must send some Ether");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public reentrancyGuard {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount; // Effect
        (bool sent, ) = msg.sender.call{value: _amount}(""); // Interaction
        require(sent, "Failed to send Ether");
    }

    function resetBalance(address _user) public onlyOwner {
        balances[_user] = 0;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        transferOwnership(_newOwner);
    }
}
