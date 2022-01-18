import { ethers } from "hardhat"
import { expect } from "chai"
import { BigNumber } from "ethers"


describe ("Test smart contract Agriculture.sol", function() {
    
    const AgricultureData = async () => {
        const [owner, user1, user2, user3, user4] = await ethers.getSigners();
        const Agriculture = await ethers.getContractFactory("Agriculture");
        const AgricultureDeploy = await Agriculture.connect(owner).deploy();


        return {
            owner,
            user1, user2, user3, user4,
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

})