import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { Crowdfunding } from "../typechain";

describe("Crowdfunding", function () {
  let crowdfunding: Crowdfunding,
    user1: SignerWithAddress,
    user2: SignerWithAddress;

  const ONE_ETHER = ethers.utils.parseEther("1");

  // setting up contract before every test case
  beforeEach(async function () {
    [user1, user2] = await ethers.getSigners();

    // get the contract abi for deployment
    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");

    // deploy the contract
    crowdfunding = await Crowdfunding.deploy();
  });

  it("Should fail querying non-existent project", async function () {
    await expect(crowdfunding.searchForProject(0)).to.be.revertedWith(
      "Project with given id does not exist"
    );

    await expect(crowdfunding.withdrawlFunds(0)).to.be.revertedWith(
      "Project with given id does not exist"
    );
  });

  it("Should fail querying contibution for non-existent project", async function () {
    await expect(
      crowdfunding.retrieveContributions(user1.address, 0)
    ).to.be.revertedWith("Project with given id does not exist");
  });

  it("Should fail participating in non-existent project", async function () {
    await expect(crowdfunding.participateToProject(0)).to.be.revertedWith(
      "Project with given id does not exist"
    );
  });

  it("Should fail withdrawing from non-existent project", async function () {
    await expect(crowdfunding.withdrawlFunds(0)).to.be.revertedWith(
      "Project with given id does not exist"
    );
  });

  it("Should fail creating project with invalid title", async function () {
    await expect(
      crowdfunding.createProject("", "description", ONE_ETHER)
    ).to.be.revertedWith("Title must not be empty");
  });

  it("Should fail creating project with invalid description", async function () {
    await expect(
      crowdfunding.createProject("title", "", ONE_ETHER)
    ).to.be.revertedWith("Description must not be empty");
  });

  it("Should fail creating project with invalid participation amount", async function () {
    await expect(
      crowdfunding.createProject("title", "description", 0)
    ).to.be.revertedWith("Participation amount must be greater than 0");
  });

  it("Should create new project", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
  });

  it("Should emit ProjectCreated on creating a new project", async function () {
    // check for emitted event with correct parameters
    await expect(
      crowdfunding
        .connect(user1)
        .createProject("title", "description", ONE_ETHER)
    )
      .to.emit(crowdfunding, "ProjectCreated")
      .withArgs(0, user1.address);
  });

  it("Should record new project", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // check recorded project variables
    const project = await crowdfunding.searchForProject(0);
    expect(project.title).to.equal("title");
    expect(project.description).to.equal("description");
    expect(project.participationAmount).to.equal(ONE_ETHER);
    expect(project.totalFundingAmount).to.equal(0);
    expect(project.owner).to.equal(user1.address);
  });

  it("Should participate in project", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
  });

  it("Should emit ParticipatedToProject on participating in a project", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // check for emitted event with correct parameters
    await expect(
      crowdfunding.connect(user2).participateToProject(0, { value: ONE_ETHER })
    )
      .to.emit(crowdfunding, "ParticipatedToProject")
      .withArgs(0, user2.address, ONE_ETHER);
  });

  it("Should transfer ether to contract on participation", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // check for ether transfer on function call
    await expect(() =>
      crowdfunding.connect(user2).participateToProject(0, { value: ONE_ETHER })
    ).to.changeEtherBalances(
      [user2, crowdfunding],
      [ONE_ETHER.mul(-1), ONE_ETHER]
    );
  });

  it("Should record contibution correctly", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // get user 1 and user 2 contributions
    const contribution1 = await crowdfunding.retrieveContributions(
      user1.address,
      0
    );
    const contribution2 = await crowdfunding.retrieveContributions(
      user2.address,
      0
    );
    // check recorded contributions
    expect(contribution1).to.equal(0);
    expect(contribution2).to.equal(ONE_ETHER);
  });

  it("Should fail participate in project with invalid ether amount", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await expect(
      crowdfunding
        .connect(user2)
        .participateToProject(0, { value: ONE_ETHER.sub(1) })
    ).to.be.revertedWith("Not enough funds sent");
  });

  it("Should withdraw funds for project by owner", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // user 1 withdraws funds
    await crowdfunding.connect(user1).withdrawlFunds(0);
  });

  it("Should emit FundsWithdrawn on wthdrawing funds", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // check for emitted event with correct parameters
    await expect(crowdfunding.connect(user1).withdrawlFunds(0))
      .to.emit(crowdfunding, "FundsWithdrawn")
      .withArgs(0, user1.address, ONE_ETHER);
  });

  it("Should transfer ether to owner on withdrawing", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // check for ether transfer on function call
    await expect(() =>
      crowdfunding.connect(user1).withdrawlFunds(0)
    ).to.changeEtherBalances(
      [user1, crowdfunding],
      [ONE_ETHER, ONE_ETHER.mul(-1)]
    );
  });

  it("Should reset collected amount by withdrawing funds", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // withdraw funds by user 1
    await crowdfunding.connect(user1).withdrawlFunds(0);
    // check for reset recorded project variables
    const project = await crowdfunding.searchForProject(0);
    expect(project.totalFundingAmount).to.equal(0);
  });

  it("Should fail withdrawing funds for project by non owner", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);
    // user 2 parisipates in project
    await crowdfunding
      .connect(user2)
      .participateToProject(0, { value: ONE_ETHER });
    // should fail withdrawing funds by user 2
    await expect(
      crowdfunding.connect(user2).withdrawlFunds(0)
    ).to.be.revertedWith("Only the project owner can call this function");
  });

  it("Should fail withdrawing with no available funds", async function () {
    // user 1 creates project
    await crowdfunding
      .connect(user1)
      .createProject("title", "description", ONE_ETHER);

    // should fail withdrawing funds by user 2
    await expect(
      crowdfunding.connect(user1).withdrawlFunds(0)
    ).to.be.revertedWith("No funds to withdraw");
  });
});
