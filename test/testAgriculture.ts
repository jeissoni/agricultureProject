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
            const {user1, AgricultureDeploy} = await AgricultureData()
           
            const idHarvest : number = 1
            const treeNumber : number = 100
            const amount = ethers.utils.parseEther("1")

            await expect(AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                idHarvest, treeNumber, amount
            )).to.be.revertedWith("The Harvest no exists")

        })


        it("cannot invest in a harvers that is pause", async () =>{
            const {owner, user1, AgricultureDeploy} = await AgricultureData()

            //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
            //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address,
                "Prueba",
                10,
                10,
                false,
                10,
                10
            )
            //saber el id de la plantacion 
            const currentIdHarvest : BigNumber = await AgricultureDeploy.getCurrentIdHarvest();

                        //pausar la plantacion 
            await AgricultureDeploy.connect(owner).pauseHarvest(currentIdHarvest.sub(1))

            const idHarvest : number = 1
            const treeNumber : number = 100
            const amount = ethers.utils.parseEther("1")

            await expect(AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                idHarvest, treeNumber, amount
            )).to.be.revertedWith("The harvest is Pause")
            
        })

        it("do not invest if the harvers is not in RECEIVE_FUNDS", async () =>{
            const {owner, user1, AgricultureDeploy} = await AgricultureData()
            //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
            //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address,
                "Prueba",
                10,
                10,
                false,
                10,
                10
            )          

            const idHarvest : number = 1
            const treeNumber : number = 100
            const amount = ethers.utils.parseEther("1")

            await expect(AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                idHarvest, treeNumber, amount
            )).to.be.revertedWith("The state from harvest is not RECEIVE_FUNDS")
        })

        it("verify that you have the necessary funds", async () =>{
            const {owner, user1, AgricultureDeploy} = await AgricultureData()
             //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
             //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address,
                "Prueba",
                10,
                10,
                false,
                10,
                10
            ) 

            const currrentIdHarvest : BigNumber = await AgricultureDeploy.connect(owner).getCurrentIdHarvest()

            const lastIdHarvest : BigNumber = currrentIdHarvest.sub(1)

            await AgricultureDeploy.connect(owner).changeStateHarvestToAnalysis(lastIdHarvest)            
            await AgricultureDeploy.connect(owner).changeStateHarvestToValidated(lastIdHarvest)
            await AgricultureDeploy.connect(owner).changeStateHarvestToReceiveFunds(lastIdHarvest)

            const idHarvest : number = 1
            const treeNumber : number = 100
            const amount = ethers.utils.parseEther("1")

            await expect(AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                idHarvest, treeNumber, amount
            )).to.be.revertedWith("Do not have the necessary funds of USD")

        })

        it("Create investment",async () => {
            const {owner, user1, AgricultureDeploy, ERC20Deploy, owenrERC20 } = await AgricultureData()

            //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
             //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address, //farmer
                "Prueba", // nameHArvest
                10, //treeNumber
                10, //harvestDay
                false, //rebewal
                10, //salePrice 
                ethers.utils.parseEther("1") //priceTree
            ) 

            const currrentIdHarvest : BigNumber = await AgricultureDeploy.connect(owner).getCurrentIdHarvest()

            const lastIdHarvest : BigNumber = currrentIdHarvest.sub(1)

            await AgricultureDeploy.connect(owner).changeStateHarvestToAnalysis(lastIdHarvest)            
            await AgricultureDeploy.connect(owner).changeStateHarvestToValidated(lastIdHarvest)
            await AgricultureDeploy.connect(owner).changeStateHarvestToReceiveFunds(lastIdHarvest)

            
            const amount : BigNumber = ethers.utils.parseEther("1")
            await ERC20Deploy.connect(owenrERC20).transfer(
                user1.address,
                amount.mul(2)                
            )

            await ERC20Deploy.connect(user1).approve(
                AgricultureDeploy.address, 
                amount
            )
            
            await AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                lastIdHarvest,
                1,
                amount
            )         

            const currentInvestments : BigNumber = await AgricultureDeploy.getCurrentIdInvestment()

            const ivestment = await AgricultureDeploy.getIdInvestment(currentInvestments.sub(1));

            expect(ivestment.idInvestment).to.equal(currentInvestments.sub(1))
            expect(ivestment.idHarvest).to.equal(lastIdHarvest)
            expect(ivestment.treeNumber).to.equal(1)
            expect(ivestment.user).to.equal(user1.address)
            expect(ivestment.valueInvestment).to.equal(amount)      

        })

        it("update investment harvest user", async()=>{
            const {owner, user1, AgricultureDeploy, ERC20Deploy, owenrERC20 } = await AgricultureData()

            //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
             //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address, //farmer
                "Prueba", // nameHArvest
                10, //treeNumber
                10, //harvestDay
                false, //rebewal
                10, //salePrice 
                ethers.utils.parseEther("1") //priceTree
            ) 

            const currrentIdHarvest : BigNumber = await AgricultureDeploy.connect(owner).getCurrentIdHarvest()

            const lastIdHarvest : BigNumber = currrentIdHarvest.sub(1)

            await AgricultureDeploy.connect(owner).changeStateHarvestToAnalysis(lastIdHarvest)            
            await AgricultureDeploy.connect(owner).changeStateHarvestToValidated(lastIdHarvest)
            await AgricultureDeploy.connect(owner).changeStateHarvestToReceiveFunds(lastIdHarvest)

            //tranferir saldo de USD a user1
            const amount : BigNumber = ethers.utils.parseEther("1")
            await ERC20Deploy.connect(owenrERC20).transfer(
                user1.address,
                amount.mul(4)                
            )

            await ERC20Deploy.connect(user1).approve(
                AgricultureDeploy.address, 
                amount.mul(4)  
            )            


            await AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                lastIdHarvest,
                1,
                amount
            )       

            await AgricultureDeploy.connect(user1).invesmentUpdateUserHarvest(
                lastIdHarvest,
                1,
                amount
            )       
        
            const currentInvestments : BigNumber = await AgricultureDeploy.getCurrentIdInvestment()

            const ivestment = await AgricultureDeploy.getIdInvestment(currentInvestments.sub(1))

            const id : BigNumber = await AgricultureDeploy.getIdInvestmentHarvestUser(lastIdHarvest, user1.address)   

            expect(id).to.equal(ivestment.idInvestment)
            expect(amount.mul(2)).to.equal(ivestment.valueInvestment)

        })


        it("return investment harvest user",async () => {
            const {owner, user1, AgricultureDeploy, ERC20Deploy, owenrERC20 } = await AgricultureData()

            //agregar agricultor
            await AgricultureDeploy.connect(owner).addUserFarmer(user1.address)
             //crear la cosecha de prueba
            await AgricultureDeploy.connect(owner).crearteNewHarvest(
                user1.address, //farmer
                "Prueba", // nameHArvest
                10, //treeNumber
                10, //harvestDay
                false, //rebewal
                10, //salePrice 
                ethers.utils.parseEther("1") //priceTree
            ) 

            const currrentIdHarvest : BigNumber = await AgricultureDeploy.connect(owner).getCurrentIdHarvest()

            const lastIdHarvest : BigNumber = currrentIdHarvest.sub(1)


            await AgricultureDeploy.connect(owner).changeStateHarvestToAnalysis(lastIdHarvest)            
            await AgricultureDeploy.connect(owner).changeStateHarvestToValidated(lastIdHarvest)
            await AgricultureDeploy.connect(owner).changeStateHarvestToReceiveFunds(lastIdHarvest)

            //tranferir saldo de USD a user1
            const amount : BigNumber = ethers.utils.parseEther("1")
            await ERC20Deploy.connect(owenrERC20).transfer(
                user1.address,
                amount.mul(2)                
            )

            await ERC20Deploy.connect(user1).approve(
                AgricultureDeploy.address, 
                amount
            )
            
            await AgricultureDeploy.connect(user1).invesmentCreateUserHarvest(
                lastIdHarvest,
                1,
                amount
            )         

            const currentInvestments : BigNumber = await AgricultureDeploy.getCurrentIdInvestment()

            const ivestment = await AgricultureDeploy.getIdInvestment(currentInvestments.sub(1))

            const id : BigNumber = await AgricultureDeploy.getIdInvestmentHarvestUser(lastIdHarvest, user1.address)

            expect(id).to.equal(ivestment.idInvestment)
        })


        
    })

})