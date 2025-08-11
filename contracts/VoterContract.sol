pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;


contract VoterContract {
    struct Voter {
        uint weight;
        bool voted;
        uint votedPerson;
    }

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates; 

    enum VotingStages{ STARTED, ENDED, CREATED }
    VotingStages public stage;
    address public chairperson;
    mapping(address => Voter) voters;

    constructor(string[] memory candidateNames) {
        for(uint i=0;i<candidateNames.length;i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
        chairperson = msg.sender;
        stage = VotingStages.CREATED;
    } 

    modifier OnlyContractOwner() {
        require(msg.sender==chairperson, "Only chair person can perform operations");
        _;
    }

    modifier StartedStage() {
        require(stage==VotingStages.STARTED, "it must be starteed");
        _;
    }

    modifier EndedStage() {
        require(stage==VotingStages.ENDED, "it must be ended");
        _;
    }

    modifier CreatedStage() {
        require(stage==VotingStages.CREATED, "it must be created");
        _;
    }

    function startVote() public OnlyContractOwner CreatedStage{
        stage = VotingStages.STARTED;
    }

    function endVote() public OnlyContractOwner StartedStage {
        stage = VotingStages.ENDED;
    }

    function giveRightsToVote(address voterAddress) public {
        require(msg.sender == chairperson, "Voter already voted");
        require(!voters[voterAddress].voted, "Voter already voted");
        require(voters[voterAddress].weight == 0);
        voters[voterAddress].weight = 1;
    }

    function vote(uint candidateIdentifier) public StartedStage {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Voter already voted");
        require(sender.weight == 1, "User won't have permission for voting");

        sender.voted = true;
        sender.votedPerson = candidateIdentifier;

        candidates[candidateIdentifier].voteCount += 1;
    }

    function winningCandidate() public EndedStage view returns(string memory winnerName) {
        uint winningVoteCount = 0;
        
        for(uint i=0;i<candidates.length;i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }

        return winnerName;
    }

    function getCandidates() 
    public 
    view 
    returns (string[] memory candidateNames)  
    {
        candidateNames = new string[](candidates.length);
        for(uint i=0;i<candidates.length;i++) {
            candidateNames[i] = candidates[i].name;
        }
        return candidateNames;
    }
    
}