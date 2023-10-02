const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Voting", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployVoting() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user1, user2, user3, user4, user5] =
      await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();

    return { voting, owner, user1, user2, user3, user4, user5 };
  }

  describe("Voting", function () {
    it("Should set the right unlockTime", async function () {
      const { voting, owner, user1, user2, user3, user4, user5 } =
        await loadFixture(deployVoting);

      await voting.createVotingProject("project1");
      await voting.addVoteItemsToVotingProject(
        ["Person", "Person2", "Person3"],
        0
      );
      await voting.addVotersToVotingProject(
        [user1, user2, user3, user4, user5],
        0
      );
      await voting.startVoting(0);

      await voting.connect(user1).vote(0, 0);
      await voting.connect(user2).vote(0, 1);
      await voting.connect(user3).vote(0, 0);
      await voting.connect(user4).vote(0, 0);

      const ans = await voting.getVoteCount(0);
      console.log(ans);
    });
  });
});
