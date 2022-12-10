// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import {ICrowdfunding} from "./ICrowdfunding.sol";

/**
 * @title Crowdfunding
 * @notice This
 */
contract Crowdfunding is ICrowdfunding {
    uint256 private projectIdCounter;
    Project[] private projects;

    mapping(address => mapping(uint256 => uint256)) private contributions;

    /**
     * @notice Creates a new crowdfunding project. The caller of this function
     * will be the owner of the project.
     * @param _title The title of the project.
     * @param _description The description of the project.
     * @param _participationAmount The amount of ether that must be sent to the
     * project to participate to it.
     * @return The id of the created project.
     */
    function createProject(
        string calldata _title,
        string calldata _description,
        uint256 _participationAmount
    ) external override returns (uint256) {
        // create new project and push it to the projects array
        projects.push(
            Project(
                projectIdCounter,
                _title,
                _description,
                payable(msg.sender),
                _participationAmount,
                0
            )
        );
        // increment project id counter
        projectIdCounter++;

        // emit event for the created project
        emit ProjectCreated(projectIdCounter, msg.sender);

        // return the id of the created project
        return projectIdCounter - 1;
    }

    /**
     * @notice The caller of this function will participate to the project with
     * the given id. The amount of ether sent with the transaction will be
     * added to the project's balance if it is not already finished. The amount
     * of ther must be the defined participation amount.
     */
    function participateToProject(
        uint256 _projectId
    ) external payable override {
        // check if participation amount is correct
        require(
            msg.value >= projects[_projectId].participationAmount,
            "Not enough funds sent"
        );
        // update users contributions
        contributions[msg.sender][_projectId] += msg.value;

        // update total funding amount
        projects[_projectId].totalFundingAmount += msg.value;

        // emit event for the participation
        emit ParticipatedToProject(_projectId, msg.sender, msg.value);
    }

    /**
     * @notice Returns the project with the given id.
     * @param _projectId The id of the project.
     * @return The project with the given id.
     */
    function searchForProject(
        uint256 _projectId
    ) external view override returns (Project memory) {
        return projects[_projectId];
    }

    /**
     * @notice Returns the amount of ether contributed by the given contributor to
     * the project with the given id.
     * @param _contributor The address of the contributor.
     * @param _projectId The id of the project.
     * @return The amount of ether contributed by the given contributor to the
     * project with the given id.
     */
    function retrieveContributions(
        address _contributor,
        uint256 _projectId
    ) external view override returns (uint256) {
        return contributions[_contributor][_projectId];
    }

    /**
     * @notice Withdraws the funds of the project with the given id. The caller
     * must be the owner of the project.
     * @param _projectId The id of the project.
     */
    function withdrawlFunds(uint256 _projectId) external override {
        // check if caller is the owner of the project
        require(
            msg.sender == projects[_projectId].owner,
            "Only the owner can withdraw funds"
        );
        // get the amount to withdraw
        uint256 amount = projects[_projectId].totalFundingAmount;
        // reset total funding amount
        projects[_projectId].totalFundingAmount = 0;
        // emit withdrawl event
        emit FundsWithdrawn(_projectId, msg.sender, amount);
        // transfer the amount to the owner
        payable(msg.sender).transfer(amount);
    }
}
