//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Agriculture {

    uint256 private currentIdHarvest = 0;
    uint256 private currentIdInvestment = 0;
    

    struct DetailHarvest{

        uint256 idHarvest;

        string nameHarves;

        uint256 treeNumber;

        uint256 harvestDays;        
        
        bool renewal;
        
        uint256 salePrice;

        //precio por arbol
        uint256 priceTree;

        uint256 depositSaleHarvest;

    }  

    struct Investment{
        uint256 idInvestment;

        uint256 treeNumber;

        uint256 valueInvestment;

        uint256 DateInvestment;

        uint256 IdHarvest;
    }


    mapping(address => uint256[]) public UserInvestment;

    mapping(uint256 => uint256[]) public HarvesInvestment;
    
    mapping(uint256 => DetailHarvest) public IdDetailHarvest;

    mapping(address => uint256[]) public FamerHarvest; 



    mapping(address => bool) public usersTeam;

    mapping(address => bool) public userFarmer;


    event AddUserFarmer(
        address team,
        address farmer,
        uint256 date
    );

    event AddUserTeam(
        address team,
        address newTeam,
        uint256 date
    );

    event DeletUserFarmer(
        address team,
        address farmer,
        uint256 date
    );

    event DeleteUserTeam(
        address team,
        address newTeam,
        uint256 date
    );

    event CrearteNewHarvest(
        address team, 
        uint256 idHarvest,
        uint256 date
    );

    event AddFamerHarvest(
        address team, 
        uint256 idHarvest, 
        address farmer,
        uint256 date
    );


    modifier onlyTeam() {
        require(
            usersTeam[msg.sender] == true,
            "Exclusive function of the team"
        );
        _;
    }  


    constructor(){
        usersTeam[msg.sender] = true;
    } 

    //test ok
    function addUserFarmer(address newFarmer) external onlyTeam returns(bool){
        userFarmer[newFarmer] = true;
        emit AddUserFarmer(msg.sender, newFarmer, block.timestamp);
        return true;
    }
    
    //test ok
    function deleteFarmer(address farmer) external onlyTeam returns (bool){
        require(usersTeam[farmer] = true, "The address is not from a farmer");
        userFarmer[farmer] = false;
        emit DeletUserFarmer(msg.sender, farmer, block.timestamp);
        return false;
    }


    function addUserTeam(address newTeam) external onlyTeam returns(bool){
        usersTeam[newTeam] = true;
        emit AddUserTeam(msg.sender, newTeam, block.timestamp);
        return true;
    }
   
    function deleteTeam(address team) external onlyTeam returns (bool){
        require(usersTeam[team] = true, "The address is not from a Team");
        usersTeam[team] = false ;
        emit DeleteUserTeam(msg.sender, team, block.timestamp);
        return true;
    }



    //Funciones de plantaciones

    function increaseIdHarvest() private onlyTeam returns (bool){
        currentIdHarvest += 1;
        return true ;
    }

    // relaciona un cultivon con un agricultor
    function addFamerHarvest(
        address _farmer,
        uint256 _idHarves
        ) private onlyTeam returns (bool){
            require(IdDetailHarvest[_idHarves].idHarvest == _idHarves, "The Harves no exists");     
            require(userFarmer[_farmer] == true, "The addres is not a farmer");     
            FamerHarvest[_farmer].push(_idHarves);
            emit AddFamerHarvest(
                msg.sender, 
                _idHarves,
                _farmer, 
                block.timestamp            
            );
            return true;    
    }

    // funcions faltaria hacer validaciones 
    // crear un cultivo
    function crearteNewHarvest(
        string memory _nameHArve,
        uint256 _treeNumber,
        uint256 _harvesDays,
        bool _renewal, 
        uint256 _salePrice, 
        uint256 _priceTree, 
        uint256 _depositSaleHArvest
    ) private onlyTeam returns (bool){

        IdDetailHarvest[currentIdHarvest].idHarvest = currentIdHarvest;
        IdDetailHarvest[currentIdHarvest].nameHarves = _nameHArve;
        IdDetailHarvest[currentIdHarvest].treeNumber = _treeNumber;
        IdDetailHarvest[currentIdHarvest].harvestDays = _harvesDays;
        IdDetailHarvest[currentIdHarvest].renewal = _renewal;
        IdDetailHarvest[currentIdHarvest].salePrice = _salePrice;
        IdDetailHarvest[currentIdHarvest].priceTree = _priceTree;
        IdDetailHarvest[currentIdHarvest].depositSaleHarvest = _depositSaleHArvest;      

        emit CrearteNewHarvest(
            msg.sender, 
            currentIdHarvest,
            block.timestamp
        );

        increaseIdHarvest();

        return true;
    }




    //funciones de usuarios 


    //funciones de equipo


    //funciones de agricultores 



}
