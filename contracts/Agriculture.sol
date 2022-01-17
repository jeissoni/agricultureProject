//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Agriculture {

    uint private currentIdHarvest = 0;


    struct DetailUser{
        uint256 treeNumber;
        uint256 depositStableCoin;
        uint256 dateDeposit;
    }

    struct DetailHarvest{

        uint256 idHarvest;

        string nameHarves;

        uint256 treeNumber;
        uint256 harvestDays;
        
        //gramos por planta 
        bool renewal;
        //precio por gramo 
        uint256 salePrice;

        //precio por usuario
        uint256 priceTree;

        uint256 depositSaleHarvest;

        mapping(address => DetailUser) userHarvest;

    }  



    mapping(uint => DetailHarvest) public IdHarvest;

    mapping(address => uint) public FamerHarvest; 

    mapping(address => bool) public usersTeam;

    mapping(address => bool) public userFarmer;

    mapping(address => uint256[]) public userHarvest;



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




}
