const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VoterContract", () => {
  let chairPerson, voter1, voter2, voter3, voter4, voterContract, candidates, winningCandidate;
    const candidateArray = ["BJP", "Congress", "AAP"];
    beforeEach(async () => {
        [chairPerson, voter1, voter2, voter3, voter4] = await ethers.getSigners();

        const VoterContract = await ethers.getContractFactory("VoterContract");
        voterContract = await VoterContract.connect(chairPerson).deploy(
            ["BJP", "Congress", "AAP"]
        );
    
    });

    it('Get candidates', async () => {
        candidates = await voterContract.getCandidates();
        expect(candidates).to.deep.equal(candidateArray);
    })

    it("Give Permission to Vote", async () => {
        await voterContract.connect(chairPerson).giveRightsToVote(voter1.address);
        await voterContract.connect(chairPerson).giveRightsToVote(voter2.address);
        await voterContract.connect(chairPerson).giveRightsToVote(voter3.address);
        await voterContract
          .connect(chairPerson)
          .giveRightsToVote(voter4.address);

        await voterContract.connect(chairPerson).startVote();
        
        await voterContract.connect(voter1).vote(0);
        await voterContract.connect(voter2).vote(1);
        await voterContract.connect(voter3).vote(2);
        await voterContract.connect(voter4).vote(2);


        await voterContract.connect(chairPerson).endVote();

        winningCandidate = await voterContract.connect(chairPerson).winningCandidate();

        expect(winningCandidate).to.be.equal("BJP");
    });

    
});
