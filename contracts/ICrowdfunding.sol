// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/**
 * @title ICrowdfunding
 * @notice This interface defines the functions, structs and events that are
 * used and implemented by the Crowdfunding contract.
 */
interface ICrowdfunding {
    // The struct that defines a crowdfunding project.
    struct Project {
        uint256 id;
        string title;
        string description;
        address payable owner;
        uint256 participationAmount;
        uint256 totalFundingAmount;
    }

    /**
     * @notice Emitted when a new project is created.
     * @param _projectId The id of the created project.
     * @param _projectOwner The address of the project owner.
     */
    event ProjectCreated(
        uint256 indexed _projectId,
        address indexed _projectOwner
    );

    /**
     * @notice Emitted when a user participates to a project.
     * @param _projectId The id of the project.
     * @param _participant The address of the participant.
     * @param _amount The amount of ether sent by the participant.
     */
    event ParticipatedToProject(
        uint256 indexed _projectId,
        address indexed _participant,
        uint256 _amount
    );

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
    ) external returns (uint256);

    /**
     * @notice The caller of this function will participate to the project with
     * the given id. The amount of ether sent with the transaction will be
     * added to the project's balance if it is not already finished. The amount
     * of ther must be the defined participation amount.
     */
    function participateToProject(uint256 _projectId) external payable;

    /**
     * @notice Returns the project with the given id.
     * @param _projectId The id of the project.
     * @return The project with the given id.
     */
    function searchForProject(
        uint256 _projectId
    ) external view returns (Project memory);

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
    ) external returns (uint256);

    /**
     * @notice Withdraws the funds of the project with the given id. The caller
     * must be the owner of the project.
     * @param _projectId The id of the project.
     */
    function withdrawlFunds(uint256 _projectId) external;
}
