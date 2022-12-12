// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/**
 * @title ICrowdfunding
 * @author Lars Raschke
 * @dev Complete source code: https://github.com/raschke-chainsulting/crowdfunding
 * @notice This interface defines the functions, structs and events that are
 * used and implemented by the Crowdfunding contract.
 */
interface ICrowdfunding {
    // The struct that defines a crowdfunding project.
    struct Project {
        uint256 id; // unique identifier of the project
        string title; // title of the project
        string description; // description of the project
        address payable owner; // address of the projects owner
        uint256 participationAmount; // exact amount of ether that must be sent to participate to the project
        uint256 totalFundingAmount; // total amount of ether contributed to the project
        uint256 deadline; // timestamp of the projects deadline as unix timestamp in seconds
        bool withdrawn; // true if the owner of the project has already withdrawn the funds
    }

    /**
     * @notice Emitted when a new project is created.
     * @param _projectId The id of the created project.
     * @param _projectOwner The address of the project owner.
     * @param _deadline The timestamp of the deadline of the project.
     */
    event ProjectCreated(
        uint256 indexed _projectId,
        address indexed _projectOwner,
        uint256 _deadline
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
     * @notice Emitted when the owner of a project withdraws the funds of the project.
     * @param _projectId The id of the project.
     * @param _projectOwner The address of the project owner.
     * @param _amount The amount of ether withdrawn by the project owner.
     */
    event FundsWithdrawn(
        uint256 indexed _projectId,
        address indexed _projectOwner,
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
    ) external returns (uint256);

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
    function participateToProject(uint256 _projectId) external payable;

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
    function withdrawlFunds(uint256 _projectId) external;

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
    ) external view returns (uint256);
}
