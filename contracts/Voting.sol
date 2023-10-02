// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title A Voting Contract
 * @author Joshua Adesanya
 * @notice This contract is for creating a voting project, adding voters and voting on items on the voting project.
 */
contract Voting {
    // Errors
    error Voting__NotOwner();
    error Voting__NotRegistered();
    error Voting__AlreadyVoted();
    error Voting__HasNotStartedOrHasEnded();
    error Voting__ProjectDoesNotExist();

    // State Variables
    address private immutable owner;
    uint256 private vpcount;
    VotingProject[] private voteProjects;

    struct VotingProject {
        uint256 id;
        string name;
        bool status;
        address[] voters;
    }

    struct VotingItems {
        uint256 id;
        string name;
        uint256 votes;
    }

    // Events
    event voteProjectCreated(uint256 indexed id, string indexed name);
    event voteCreated(uint256 indexed count, string indexed text);

    // Mappings

    mapping(uint256 => VotingProject) private countToVoteProject;
    mapping(address => mapping(uint256 => bool)) private voterAccessToVoteProject;
    mapping(uint256 => VotingItems[]) private idToVotingItems;
    mapping(address => mapping(uint256 => bool)) private voterToVoteProject;

    // Modifiers
    modifier onlyContractOwner() {
        if (msg.sender != owner) revert Voting__NotOwner();
        _;
    }

    modifier VotingProjectExist(uint256 vid) {
        if (countToVoteProject[vid].id != vid) revert Voting__ProjectDoesNotExist();
        _;
    }

    modifier onlyVoter(uint256 vid) {
        if (voterAccessToVoteProject[msg.sender][vid] == false) revert Voting__NotRegistered();
        _;
    }

    modifier VotingOngoing(uint256 vid) {
        if (countToVoteProject[vid].status == false) revert Voting__HasNotStartedOrHasEnded();
        _;
    }

    // Constructor

    constructor() {
        owner = msg.sender;
    }

    // External Functions

    /*
     * @notice Create a Voting Project
     *  @param name, the name of the voting project
     *  @dev only contract owner can create voting project
     */
    function createVotingProject(string calldata name) external onlyContractOwner {
        address[] memory voters;
        countToVoteProject[vpcount] = VotingProject(vpcount, name, false, voters);
        emit voteProjectCreated(vpcount, name);
        vpcount++;
    }

    /*
     * @notice Add items to the voting project
     *  @param names, an array of the items to be voted upon.
     *  @param voteProjectId, The id of the voting project.
     *  @dev only contract owner can add items to the voting project
     */
    function addVoteItemsToVotingProject(string[] calldata names, uint256 voteProjectId)
        external
        onlyContractOwner
        VotingProjectExist(voteProjectId)
    {
        for (uint256 i = 0; i < names.length; i++) {
            idToVotingItems[voteProjectId].push(VotingItems(i, names[i], 0));
        }
    }

    /*
     * @notice Add voters to the voting project
     *  @param names, an array of the voters that can vote on a voting project.
     *  @param voteProjectId, The id of the voting project.
     *  @dev only contract owner can add items to the voting project
     */
    function addVotersToVotingProject(address[] calldata voters, uint256 voteProjectId)
        external
        onlyContractOwner
        VotingProjectExist(voteProjectId)
    {
        for (uint256 i = 0; i < voters.length; i++) {
            countToVoteProject[voteProjectId].voters.push(voters[i]);
            voterAccessToVoteProject[voters[i]][voteProjectId] = true;
        }
    }

    function startVoting(uint256 voteProjectId) external onlyContractOwner VotingProjectExist(voteProjectId) {
        countToVoteProject[voteProjectId].status = true;
    }

    function endVoting(uint256 voteProjectId) external onlyContractOwner VotingProjectExist(voteProjectId) {
        countToVoteProject[voteProjectId].status = false;
    }

    /*
     *  @notice vote on an exisitng Voting Project
     *  @param voteProjectId, The id of the voting project.
     *  @param itemId, The id of the item in the voting project that is voted for.
     *  @dev only voters added to the voting project can vote.
     */
    function vote(uint256 voteProjectId, uint256 itemId)
        external
        VotingProjectExist(voteProjectId)
        onlyVoter(voteProjectId)
        VotingOngoing(voteProjectId)
    {
        if (voterToVoteProject[msg.sender][voteProjectId] == true) {
            revert Voting__AlreadyVoted();
        }

        idToVotingItems[voteProjectId][itemId].votes = idToVotingItems[voteProjectId][itemId].votes + 1;
        voterToVoteProject[msg.sender][voteProjectId] = true;
    }

    // Public Functions
    /*
     *  @notice get Voting Result
     *  @param voteProjectId, The id of the voting project.
     *  @dev any one can get the voting result.
     */
    function getVoteCount(uint256 voteProjectId)
        public
        view
        VotingProjectExist(voteProjectId)
        returns (VotingItems[] memory)
    {
        return idToVotingItems[voteProjectId];
    }
}
