import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { Crowdfunding } from "../typechain";

describe("Crowdfunding", function () {
  let crowdfunding: Crowdfunding,
    user1: SignerWithAddress,
    user2: SignerWithAddress;

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
      crowdfunding.createProject("", "description", 10)
    ).to.be.revertedWith("Title must not be empty");
  });

  it("Should fail creating project with invalid description", async function () {
    await expect(
      crowdfunding.createProject("title", "", 10)
    ).to.be.revertedWith("Description must not be empty");
  });

  it("Should fail creating project with invalid participation amount", async function () {
    await expect(
      crowdfunding.createProject("title", "description", 0)
    ).to.be.revertedWith("Participation amount must be greater than 0");
  });

  it("Should create new project", async function () {
    await crowdfunding.createProject("title", "description", 10);
  });

  it("Should emit ProjectCreated on creating a new project", async function () {
    await expect(crowdfunding.createProject("title", "description", 10))
      .to.emit(crowdfunding, "ProjectCreated")
      .withArgs(0, user1.address);
  });

  it("Should record new project", async function () {
    await crowdfunding.createProject("title", "description", 10);

    const project = await crowdfunding.searchForProject(0);

    expect(project.title).to.equal("title");
    expect(project.description).to.equal("description");
    expect(project.participationAmount).to.equal(10);
    expect(project.totalFundingAmount).to.equal(0);
    expect(project.owner).to.equal(user1.address);
  });

  it("Should participate in project", async function () {
    await crowdfunding.createProject("title", "description", 10);

    await crowdfunding.participateToProject(0, { value: 10 });
  });

  it("Should emit ParticipatedToProject on participating in a project", async function () {
    await crowdfunding.createProject("title", "description", 10);

    await expect(crowdfunding.participateToProject(0, { value: 10 }))
      .to.emit(crowdfunding, "ParticipatedToProject")
      .withArgs(0, user1.address, 10);
  });

  it("Should record contibution correctly", async function () {
    await crowdfunding.createProject("title", "description", 10);

    await crowdfunding.participateToProject(0, { value: 10 });

    const contribution = await crowdfunding.retrieveContributions(
      user1.address,
      0
    );

    expect(contribution).to.equal(10);
  });

  it("Should withdraw funds for project by owner", async function () {
    await crowdfunding.createProject("title", "description", 10);

    await crowdfunding.connect(user2).participateToProject(0, { value: 10 });

    await crowdfunding.withdrawlFunds(0);
  });

  it("Should emit FundsWithdrawn on wthdrawing funds", async function () {
    await crowdfunding.connect(user1).createProject("title", "description", 10);

    await crowdfunding.connect(user2).participateToProject(0, { value: 10 });

    await expect(crowdfunding.withdrawlFunds(0))
      .to.emit(crowdfunding, "FundsWithdrawn")
      .withArgs(0, user1.address, 10);
  });

  it("Should reset collected amount by withdrawing funds", async function () {
    await crowdfunding.connect(user1).createProject("title", "description", 10);

    await crowdfunding.connect(user2).participateToProject(0, { value: 10 });

    await crowdfunding.withdrawlFunds(0);

    const project = await crowdfunding.searchForProject(0);

    expect(project.totalFundingAmount).to.equal(0);
  });

  it("Should fail withdrawing funds for project by non owner", async function () {
    await crowdfunding.connect(user1).createProject("title", "description", 10);

    await crowdfunding.connect(user2).participateToProject(0, { value: 10 });

    await expect(
      crowdfunding.connect(user2).withdrawlFunds(0)
    ).to.be.revertedWith("Only the project owner can call this function");
  });
});
