// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Raffle Contract
 * @notice This contract is for creating a raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */

contract Lottery is VRFConsumerBaseV2Plus {
    error Raffle__TransferFailed();
    error Raffle__NotOpen();

    enum RaffleState {
        OPEN, // 0
        CLOSED // 1
    } // this enum controls the contract's lifecycle. It enables the opening and closing of the raffle

    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    //past requestIDs
    uint256[] public requestIds;
    uint256 public lastRequestId;

    //lottery variables
    uint256 public ticketPrice = 0.01 ether; //ticket price
    uint256 private lastTimeStamp; //this is the time at the beginning of each lottery round
    address payable[] private players; //list of players
    address private recentWinner; // last winner
    string[] public sponsors; //sponsors of the contract
    RaffleState private raffleStatus; //state variable showing the status of the contract

    // Chainlink VRF Variables
    address private vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B; // The address of the Chainlink VRF Coordinator contract for the sepolia testnet
    uint256 private immutable subscriptionId =
        27814786261777184721186320083842558020825769777178635127706371653407347689729; // The subscription ID that this contract uses for funding requests. For the purpose of this contract, it is hardcoded.
    bytes32 private immutable gasLane =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; //key hash
    uint32 private immutable callbackGasLimit = 500000; // maximum gas limit for the callback function
    uint16 private constant REQUEST_CONFIRMATIONS = 3; // number of confirmations for the VRF request
    uint32 private constant NUM_WORDS = 1; // number of random numbers that you want
    
    constructor() VRFConsumerBaseV2Plus(vrfCoordinator) {
        lastTimeStamp = block.timestamp; // the beginning of each lottery round
        raffleStatus = RaffleState.OPEN; // opens the contract to allow players
    }

    /**
     * @dev Allows a player to buy a ticket and enter the raffle. Ensures that the correct ticket price is paid and that the raffle is open.
     * Emits an `EnteredRaffle` event with the player's address.
     */
    function buyTicketAndEnterRaffle() public payable {
        //checks
        require(
            msg.value == ticketPrice,
            "Did not send the right amount of ETH"
        );
        if (raffleStatus != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        //effect
        players.push(payable(msg.sender));
        //interactions
        emit EnteredRaffle(msg.sender);
    }

    /**
     * @dev Allows sponsors to donate Ether to the contract and adds the sponsor's name to the sponsors array.
     * Requires the donation amount to be greater than 0.
     */
    function sponsorDonation(string memory _sponsorName) public payable {
        require(msg.value > 0, "Donation must be greater than 0.");
        sponsors.push(_sponsorName);
    }

    /**
     * @dev Checks if all conditions to pick a winner are met:
     *  - Raffle state is open
     *  - Contract has a positive balance
     *  - There are players who entered the raffle
     * Returns `true` if all conditions are met, otherwise `false`.
     */
    function checkConditions() public view returns (bool conditionsMet) {
        bool isOpen = raffleStatus == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = players.length > 0;

        conditionsMet = (isOpen && hasBalance && hasPlayers);
        return conditionsMet;
    }

    /**
     * @dev Requests random words from Chainlink VRF to determine the raffle winner.
     * Closes the raffle before making the request to prevent further entries.
     * If conditions are met, a request for random words is made and the request ID is saved.
     */
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        if (checkConditions() == true) {
            raffleStatus = RaffleState.CLOSED;

            requestId = s_vrfCoordinator.requestRandomWords(
                VRFV2PlusClient.RandomWordsRequest({
                    keyHash: gasLane,
                    subId: subscriptionId,
                    requestConfirmations: REQUEST_CONFIRMATIONS,
                    callbackGasLimit: callbackGasLimit,
                    numWords: NUM_WORDS,
                    extraArgs: VRFV2PlusClient._argsToBytes(
                        VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                    )
                })
            );

            s_requests[requestId] = RequestStatus({
                randomWords: new uint256[](0),
                exists: true,
                fulfilled: false
            });
            requestIds.push(requestId);
            lastRequestId = requestId;
            return requestId;
        }
    }

    /**
     * @dev Chainlink VRF callback function that is called once the random words request is fulfilled.
     * Uses the random word to select a winner, resets the raffle state, and transfers the balance to the winner.
     * Emits a `WinnerPicked` event with the winner's address.
     * This function runs automatically once a random number has been generated
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_requests[requestId].exists, "request not found");
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = _randomWords;

        uint256 indexOfWinner = _randomWords[0] % players.length;
        address payable _recentWinner = players[indexOfWinner];
        recentWinner = _recentWinner;

        raffleStatus = RaffleState.OPEN;
        players = new address payable[](0);
        lastTimeStamp = block.timestamp;
        emit WinnerPicked(recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    /**
     * @dev Toggles the raffle state between OPEN and CLOSED.
     * Useful for pausing and resuming the raffle manually.
     */
    function changeRaffleState() public onlyOwner {
        if (raffleStatus == RaffleState.OPEN) {
            raffleStatus = RaffleState.CLOSED;
        } else {
            raffleStatus = RaffleState.OPEN;
        }
    }

    /**
     * @dev Returns the status of a specific request given its `requestId`.
     * Checks if the request exists and returns whether it's fulfilled and the associated random words.
     */
    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    /**
     * @dev Returns the total balance of the contract, representing the prize pool for the raffle.
     */
    function checkPrizePool() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the current state of the raffle (OPEN or CLOSED).
     */
    function getRaffleState() external view returns (RaffleState) {
        return raffleStatus;
    }

    /**
     * @dev Returns the address of a player at a specific `index` in the players array.
     */
    function getPlayer(uint256 index) external view returns (address) {
        return players[index];
    }

    /**
     * @dev Returns the most recent winner of the raffle.
     */
    function getRecentWinner() external view returns (address) {
        return recentWinner;
    }

    /**
     * @dev Returns the number of players currently entered in the raffle.
     */
    function getNumberOfPlayers() external view returns (uint256) {
        return players.length;
    }

    /**
     * @dev Returns the timestamp of the beginning of the current raffle round.
     */
    function getLastTimeStamp() external view returns (uint256) {
        return lastTimeStamp;
    }
}