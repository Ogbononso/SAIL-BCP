// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

contract randomNumber is VRFConsumerBaseV2Plus {
    bytes32 internal keyHash; // Identifies which chainlink Oracle to use
    uint internal fee; // fee to get random number
    uint public randomResult;

    constructor() {
        VRFConsumerBaseV2Plus(
            0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // VRF coordinator
            0x779877A7B0D9E8603169DdbD7836e478b4624789, // Link token      
        ) {
            keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; 
            fee = 20 * 10 ** 18; // 20 LINK
        }
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require (LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
        randomResult = randomness;
    }
}