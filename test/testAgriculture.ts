import { ethers } from "hardhat"
import { expect } from "chai"
import { BigNumber } from "ethers"


describe ("Test smart contract Agriculture.sol", function() {
    
    const AgricultureData = async () => {

        const nameERC20: string  = "USDT" 
        const symbolERC20 : string = "USDT"
        const decimals = 18
        const totalValue = ethers.utils.parseEther("100")
 

        const [owner, owenrERC20, user1, user2, user3, user4] = await ethers.getSigners();

        const ERC20 = await ethers.getContractFactory("ERC20")
        
        const ERC20Deploy = await ERC20.connect(owenrERC20).deploy(
             nameERC20,
             symbolERC20,
             decimals, 
             totalValue
         )


        const Agriculture = await ethers.getContractFactory("Agriculture");
        const AgricultureDeploy = await Agriculture.connect(owner).deploy(ERC20Deploy.address);


        return {
            owner,
            owenrERC20,
            user1, user2, user3, user4,
            ERC20Deploy,
            AgricultureDeploy            
        }
    }


    

    describe("Test Famer", function () {

        it("The account you display is the team account", async() => {

        const {owner, user1, AgricultureDeploy} = await AgricultureData()

        const isTeam : boolean = await AgricultureDeploy.usersTeam(owner.address)
        const isUser : boolean = await AgricultureDeploy.usersTeam(user1.address)

        expect(isTeam).to.equal(true)
        expect(isUser).to.equal(false)

        })      


        it("Add new farmer", async () =>{
            const {owner, user1, AgricultureDeploy} = await AgricultureData()

            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)

            const isFarmer : boolean = await AgricultureDeploy.userFarmer(user1.address)
            expect(isFarmer).to.equal(true)
        })


        it("Delete farmer", async () => {
            const {owner, user1, AgricultureDeploy} = await AgricultureData()

            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)

            await AgricultureDeploy.connect(owner).deleteFarmer(user1.address)

            const isFarmer : boolean = await AgricultureDeploy.userFarmer(user1.address)

            expect(isFarmer).to.equal(false)

        })

        it ("Only Team can add new farmer", async()=>{
            const {user1, AgricultureDeploy} = await AgricultureData()

            await expect(AgricultureDeploy.connect(user1).addUserFarmer(user1.address))
            .to.be.revertedWith('Exclusive function of the team');
        })
    })

    describe("Test User", function(){

        it("cannot invest in a harvers that is not created", async () =>{
            const {owner, user1, AgricultureDeploy, ERC20Deploy} = await AgricultureData()

            const idHarvest : number = 1
            const treeNumber : number = 100
            const amount = ethers.utils.parseEther("1")



            await expect(AgricultureDeploy.connect(user1).invesmentUserHarvest(
                idHarvest, treeNumber, amount
            )).to.be.revertedWith("The Harves no exists")

        })

        it("cannot invest in a harvers that is pause", async () =>{
            
        })
        
    })

})