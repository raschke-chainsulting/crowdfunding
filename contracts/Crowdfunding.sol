// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import {ICrowdfunding} from "./ICrowdfunding.sol";

/**
 * @title Crowdfunding
 * @author Lars Raschke
 * @dev Complete source code: https://github.com/raschke-chainsulting/crowdfunding
 * @notice This contract implements a crowdfunding platform. It allows users to
 * create crowdfunding projects and participate to them. The owner of a project
 * can withdraw the funds of the project when a defined deadline is reached.
 */
contract Crowdfunding is ICrowdfunding {
    // counter to generate unique project ids
    uint256 private projectIdCounter;

    // array to store all projects
    Project[] private projects;

    // mapping to store all contributions of users to projects
    // user address => project id => amount of ether contributed
    mapping(address => mapping(uint256 => uint256)) private contributions;

    // modifier to check if the project with the given id exists
    modifier projectExists(uint256 _projectId) {
        require(
            _projectId < projectIdCounter,
            "Project with given id does not exist"
        );
        _;
    }

    // modifier to check if the caller of a function is the owner of the project
    modifier onlyProjectOwner(uint256 _projectId) {
        require(
            projects[_projectId].owner == msg.sender,
            "Only the project owner can call this function"
        );
        _;
    }

    /**
     * @notice Creates a new crowdfunding project. The caller of this function
     * will be the owner of the project.
     * @param _title The title of the project.
     * @param _description The description of the project.
     * @param _participationAmount The amount of ether that must be sent to the
     * project to participate to it.
     * @return The id of the created project.
     *
     * @custom:requirements
     * - The title must not be empty.
     * - The description must not be empty.
     * - The participation amount must be greater than 0.
     * - The deadline must be in the future.
     */
    function createProject(
        string calldata _title,
        string calldata _description,
        uint256 _participationAmount,
        uint256 _deadline
    ) external override returns (uint256) {
        // check if input parameters are valid
        require(bytes(_title).length > 0, "Title must not be empty");
        require(
            bytes(_description).length > 0,
            "Description must not be empty"
        );
        require(
            _participationAmount > 0,
            "Participation amount must be greater than 0"
        );
        require(_deadline > block.timestamp, "Deadline must be in the future");

        // create new project and push it to the projects array
        projects.push(
            Project(
                projectIdCounter, // id of the project
                _title, // title of the project
                _description, // description of the project
                payable(msg.sender), // owner of the project
                _participationAmount, // participation amount of the project
                0, // total collected funding amount of the project
                _deadline, // deadline of the project
                false // if the owner of the project has withdrawn the funds
            )
        );

        // emit event for the created project
        emit ProjectCreated(projectIdCounter, msg.sender, _deadline);

        // increment project id counter
        projectIdCounter++;

        // return the id of the created project
        return projectIdCounter - 1;
    }

    /**
     * @notice The caller of this function will participate to the project with
     * the given id. The amount of ether sent with the transaction will be
     * added to the project's balance if it is not already finished. The amount
     * of ether must be the defined participation amount. Users can participate
     * to a project multiple times.
     *
     * @custom:requirements
     * - The project with the given id must exist.
     * - The amount of ether sent with the transaction must be the defined
     *  participation amount.
     * - The deadline of the project must not have passed yet.
     */
    function participateToProject(
        uint256 _projectId
    ) external payable override projectExists(_projectId) {
        // check if participation amount is correct
        require(
            msg.value == projects[_projectId].participationAmount,
            "Participation amount is incorrect"
        );
        require(
            block.timestamp < projects[_projectId].deadline,
            "Deadline has passed"
        );

        // update users contributions
        contributions[msg.sender][_projectId] += msg.value;

        // update total funding amount
        projects[_projectId].totalFundingAmount += msg.value;

        // emit event for the participation
        emit ParticipatedToProject(_projectId, msg.sender, msg.value);
    }

    /**
     * @notice Withdraws the funds of the project with the given id. The caller
     * must be the owner of the project. The withdrawl flag will be set by calling
     * this function allowing the owner to withdraw the funds only once.
     * @param _projectId The id of the project.
     *
     * @custom:requirements
     * - The project with the given id must exist.
     * - The caller of this function must be the owner of the project.
     * - The deadline of the project must have passed.
     * - The project must have funds to withdraw.
     * - The funds must not have been withdrawn yet.
     */
    function withdrawlFunds(
        uint256 _projectId
    ) external override projectExists(_projectId) onlyProjectOwner(_projectId) {
        // check if withdrawl has already been done
        require(
            !projects[_projectId].withdrawn,
            "Funds have already been withdrawn"
        );
        // check if the dead line has passed
        require(
            block.timestamp > projects[_projectId].deadline,
            "Deadline has not passed yet"
        );
        // check if there are funds to withdraw
        require(
            projects[_projectId].totalFundingAmount > 0,
            "No funds to withdraw"
        );

        // set withdrawn flag to true to prevent multiple withdrawls
        projects[_projectId].withdrawn = true;
        // emit withdrawl event
        emit FundsWithdrawn(
            _projectId,
            msg.sender,
            projects[_projectId].totalFundingAmount
        );
        // transfer the amount to the owner
        payable(msg.sender).transfer(projects[_projectId].totalFundingAmount);
    }

    /**
     * @notice Returns the project data with the given id.
     * @param _projectId The id of the project.
     * @return The project data for the given id.
     *
     * @custom:requirements
     * - The project with the given id must exist.
     */
    function searchForProject(
        uint256 _projectId
    )
        external
        view
        override
        projectExists(_projectId)
        returns (Project memory)
    {
        return projects[_projectId];
    }

    /**
     * @notice Returns the amount of ether contributed by the given contributor to
     * the project with the given id.
     * @param _contributor The address of the contributor.
     * @param _projectId The id of the project.
     * @return The amount of ether contributed by the given contributor to the
     * project with the given id.
     *
     * @custom:requirements
     * - The project with the given id must exist.
     */
    function retrieveContributions(
        address _contributor,
        uint256 _projectId
    ) external view override projectExists(_projectId) returns (uint256) {
        return contributions[_contributor][_projectId];
    }
}
