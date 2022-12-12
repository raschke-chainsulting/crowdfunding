# Crowdfunding

*Lars Raschke*

> Crowdfunding

This contract implements a crowdfunding platform. It allows users to create crowdfunding projects and participate to them. The owner of a project can withdraw the funds of the project when a defined deadline is reached.

*Complete source code: https://github.com/raschke-chainsulting/crowdfunding*

## Methods

### createProject

```solidity
function createProject(string _title, string _description, uint256 _participationAmount, uint256 _deadline) external nonpayable returns (uint256)
```

Creates a new crowdfunding project. The caller of this function will be the owner of the project.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _title | string | The title of the project. |
| _description | string | The description of the project. |
| _participationAmount | uint256 | The amount of ether that must be sent to the project to participate to it. |
| _deadline | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The id of the created project. |

### participateToProject

```solidity
function participateToProject(uint256 _projectId) external payable
```

The caller of this function will participate to the project with the given id. The amount of ether sent with the transaction will be added to the project&#39;s balance if it is not already finished. The amount of ether must be the defined participation amount. Users can participate to a project multiple times.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId | uint256 | undefined |

### retrieveContributions

```solidity
function retrieveContributions(address _contributor, uint256 _projectId) external view returns (uint256)
```

Returns the amount of ether contributed by the given contributor to the project with the given id.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _contributor | address | The address of the contributor. |
| _projectId | uint256 | The id of the project. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of ether contributed by the given contributor to the project with the given id. |

### searchForProject

```solidity
function searchForProject(uint256 _projectId) external view returns (struct ICrowdfunding.Project)
```

Returns the project data with the given id.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId | uint256 | The id of the project. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | ICrowdfunding.Project | The project data for the given id. |

### withdrawlFunds

```solidity
function withdrawlFunds(uint256 _projectId) external nonpayable
```

Withdraws the funds of the project with the given id. The caller must be the owner of the project. The withdrawl flag will be set by calling this function allowing the owner to withdraw the funds only once.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId | uint256 | The id of the project. |



## Events

### FundsWithdrawn

```solidity
event FundsWithdrawn(uint256 indexed _projectId, address indexed _projectOwner, uint256 _amount)
```

Emitted when the owner of a project withdraws the funds of the project.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId `indexed` | uint256 | undefined |
| _projectOwner `indexed` | address | undefined |
| _amount  | uint256 | undefined |

### ParticipatedToProject

```solidity
event ParticipatedToProject(uint256 indexed _projectId, address indexed _participant, uint256 _amount)
```

Emitted when a user participates to a project.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId `indexed` | uint256 | undefined |
| _participant `indexed` | address | undefined |
| _amount  | uint256 | undefined |

### ProjectCreated

```solidity
event ProjectCreated(uint256 indexed _projectId, address indexed _projectOwner, uint256 _deadline)
```

Emitted when a new project is created.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _projectId `indexed` | uint256 | undefined |
| _projectOwner `indexed` | address | undefined |
| _deadline  | uint256 | undefined |



