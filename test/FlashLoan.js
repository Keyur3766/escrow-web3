const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

const ether = tokens;

describe('FlashLaoan', () => {
    let token,flashLoan,flashLoanReceiver;

    let deployer;
    beforeEach(async() => {
        // Setup accounts
        const accounts = await ethers.getSigners();
        deployer = accounts[0];

        // Deploy contracts
        const FlashLoan = await ethers.getContractFactory('FlashLoan');
        const FlashLoanReceiver = await ethers.getContractFactory('FlashLoanReceiver');
        const Token = await ethers.getContractFactory('Token');

        token = await Token.deploy('Keyur','Kcode','1000000');

        // Deploy Flashloan Pool
        flashLoan = await FlashLoan.deploy(token.address);


        // Approve the token before deposit
        let transaction = await token.connect(deployer).approve(flashLoan.address, tokens(1000000));
        await transaction.wait();

        // Deposit the tokens
        transaction = await flashLoan.connect(deployer).depositTokens(tokens(1000000));
        await transaction.wait();


        // Deploy FlashLoan Receiver
        flashLoanReceiver = await FlashLoanReceiver.deploy(flashLoan.address);

    })

    describe('Deployment', ()=>{
        it('sends token to the flashloan pool contract', async() =>{
            expect(await token.balanceOf(flashLoan.address)).to.be.equal(tokens(1000000));
        })
    })

    describe("Borrowing funds", () => {
        it('Borrows funds from the pool', async() => {
            let amount = tokens(100);
            let transaction = await flashLoanReceiver.connect(deployer).executeFlashLoan(amount);
            await transaction.wait();
            
            await expect(transaction).to.emit(flashLoanReceiver,'LoanReceived')
            .withArgs(token.address,amount);

        })
    })
})