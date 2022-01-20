//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./IERC20.sol";



contract Agriculture {

    IERC20 public USD;

    uint256 private currentIdHarvest;
    uint256 private currentIdInvestment;

    // expresado en ETH => % * 1 ether / 100 
    uint256 private feeTransaction ;

    enum stateHarvest {
        CREATED,
        ANALYSIS,
        VALIDATED,
        RECEIVE_FUNDS,
        EXECUTION,
        FINALIZED        
    }

    struct DetailHarvest {
        uint256 idHarvest;
        string nameHarves;
        uint256 treeNumber;
        uint256 harvestDays;
        bool renewal;
        uint256 salePrice;
        //precio por arbol
        uint256 priceTree;
        uint256 depositSaleHarvest;
        bool pause;
        stateHarvest state;
    }

    struct Investment {
        uint256 idInvestment;
        uint256 idHarvest;
        uint256 treeNumber;
        uint256 valueInvestment;
        uint256 DateInvestment;
    }

    mapping(address => uint256[]) public UserInvestment;

    mapping(uint256 => uint256[]) public HarvesInvestment;

    mapping(uint256 => DetailHarvest) public IdDetailHarvest;

    mapping(address => uint256[]) public FamerHarvest;

    mapping(address => bool) public usersTeam;

    mapping(address => bool) public userFarmer;

    mapping(uint256 => uint256) public treesSoldHarvest;


    event AddUserFarmer(address team, address farmer, uint256 date);

    event AddUserTeam(address team, address newTeam, uint256 date);

    event DeletUserFarmer(address team, address farmer, uint256 date);

    event DeleteUserTeam(address team, address newTeam, uint256 date);

    event CrearteNewHarvest(address team, uint256 idHarvest, uint256 date);

    event AddFamerHarvest(
        address team,
        uint256 idHarvest,
        address farmer,
        uint256 date
    );

    event ChangeStateHarvest(
        address team,
        uint256 idHarvest,
        stateHarvest state,
        uint256 date
    );

    event Pause(
        address team,
        uint256 idHarvest,
        bool isPause,
        uint256 date
    );

    event Unpause(
        address team,
        uint256 idHarvest,
        bool isPause,
        uint256 date
    );

    event SetFeeTransaction(
        address team,
        uint256 fee,
        uint256 date
    );



    modifier onlyTeam() {
        require(
            usersTeam[msg.sender] == true,
            "Exclusive function of the team"
        );
        _;
    }

    //aun hay arboles por vender?
    function treesToSell(uint256 _idHarvest) external view returns (bool){
        bool isTreesToSell = false ;
        if (treesSoldHarvest[_idHarvest] < IdDetailHarvest[_idHarvest].treeNumber){
            isTreesToSell = true;
        }
        return isTreesToSell;
    }

    //Esta una cosecha pausada?
    function isPaused(uint256 _idHarvest) public view returns (bool){
        return  IdDetailHarvest[_idHarvest].pause;
    }

    // function isHarverstExists(uint256 _idHarvest) public view returns (bool){
    //     bool isExist = false;
    //     if (IdDetailHarvest[_idHarvest].idHarvest == _idHarvest){
    //         isExist = true;
    //     }
    //     return isExist;
    // }

    //recibier en expresado en ETH
    function setFeeTransaction(uint256 _fee) private onlyTeam returns(bool){
        feeTransaction = _fee;
        emit SetFeeTransaction(
            msg.sender,
            _fee,
            block.timestamp
        );
        return true;
    }

    function getAmountAndFee(uint256 _amount) private view returns(uint256){
        uint256 currentTransactionFee = (_amount * feeTransaction) / 1 ether;
        uint256 amoundAndPorcentage = _amount + currentTransactionFee;
        return amoundAndPorcentage;
    }

    //test ok
    function addUserFarmer(address newFarmer) external onlyTeam returns (bool) {
        userFarmer[newFarmer] = true;
        emit AddUserFarmer(msg.sender, newFarmer, block.timestamp);
        return true;
    }

    //test ok
    function deleteFarmer(address farmer) external onlyTeam returns (bool) {
        require(usersTeam[farmer] = true, "The address is not from a farmer");
        userFarmer[farmer] = false;
        emit DeletUserFarmer(msg.sender, farmer, block.timestamp);
        return false;
    }

    function addUserTeam(address newTeam) external onlyTeam returns (bool) {
        usersTeam[newTeam] = true;
        emit AddUserTeam(msg.sender, newTeam, block.timestamp);
        return true;
    }

    function deleteTeam(address team) external onlyTeam returns (bool) {
        require(usersTeam[team] = true, "The address is not from a Team");
        usersTeam[team] = false;
        emit DeleteUserTeam(msg.sender, team, block.timestamp);
        return true;
    }

    
//*************************************************************************/
//                      Funciones de plantaciones
//*************************************************************************/
    function increaseIdHarvest() private returns (bool) {
        currentIdHarvest += 1;
        return true;
    }

    function increaseIdInvestment() private returns (bool){
        currentIdInvestment +=1;
        return true;
    }

    // relaciona un cultivo con un agricultor
    function addFamerHarvest(address _farmer, uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(
            IdDetailHarvest[_idHarvest].idHarvest == _idHarvest,
            "The Harves no exists"
        );

        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(userFarmer[_farmer] == true, "The addres is not a farmer");

        FamerHarvest[_farmer].push(_idHarvest);
        emit AddFamerHarvest(msg.sender, _idHarvest, _farmer, block.timestamp);
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
    ) private onlyTeam returns (bool) {
        IdDetailHarvest[currentIdHarvest].idHarvest = currentIdHarvest;
        IdDetailHarvest[currentIdHarvest].nameHarves = _nameHArve;
        IdDetailHarvest[currentIdHarvest].treeNumber = _treeNumber;
        IdDetailHarvest[currentIdHarvest].harvestDays = _harvesDays;
        IdDetailHarvest[currentIdHarvest].renewal = _renewal;
        IdDetailHarvest[currentIdHarvest].salePrice = _salePrice;
        IdDetailHarvest[currentIdHarvest].priceTree = _priceTree;
        IdDetailHarvest[currentIdHarvest]
            .depositSaleHarvest = _depositSaleHArvest;
        IdDetailHarvest[currentIdHarvest].state = stateHarvest.CREATED;
        IdDetailHarvest[currentIdHarvest].pause = false;

        emit CrearteNewHarvest(msg.sender, currentIdHarvest, block.timestamp);

        increaseIdHarvest();

        return true;
    }
//************************************************************************************/
//************************************************************************************/


//********************************************************************* */
//                     Funciones de cambio de estado
//********************************************************************* */
    function changeStateHarvestToAnalysis(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.CREATED,
            "The state from harvest is not CREATED"
        );
        IdDetailHarvest[_idHarvest].state == stateHarvest.ANALYSIS;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.ANALYSIS,
            block.timestamp
        );
        return true;
    }

    
    function changeStateHarvestToValidated(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.ANALYSIS,
            "The state from harvest is not ANALYSIS"
        );
        IdDetailHarvest[_idHarvest].state == stateHarvest.ANALYSIS;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.VALIDATED,
            block.timestamp
        );
        return true;
    }


    function changeStateHarvestToReceiveFunds(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.VALIDATED,
            "The state from harvest is not VALIDATED"
        );


        IdDetailHarvest[_idHarvest].state == stateHarvest.RECEIVE_FUNDS;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.RECEIVE_FUNDS,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToExecution(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.RECEIVE_FUNDS,
            "The state from harvest is not RECEIVE_FUNDS"
        );
        IdDetailHarvest[_idHarvest].state == stateHarvest.EXECUTION;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.EXECUTION,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToFinalized(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.EXECUTION,
            "The state from harvest is not EXECUTION"
        );
        IdDetailHarvest[_idHarvest].state == stateHarvest.FINALIZED;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.FINALIZED,
            block.timestamp
        );
        return true;
    }

    function pauseHarvest (uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {       
        require(isPaused(_idHarvest) == false, "The harvest is Pause");
        IdDetailHarvest[currentIdHarvest].pause = true;
        
        emit Pause(
            msg.sender, 
            _idHarvest, 
            true,
            block.timestamp
        );
        return true;
    }

    function unPauseHArvest(uint256 _idHarvest)
    private 
    onlyTeam
    returns (bool){
        require(isPaused(_idHarvest) == true, "The harvest is not unPause");
        IdDetailHarvest[currentIdHarvest].pause = false;
        emit Unpause(
            msg.sender, 
            _idHarvest, 
            true,
            block.timestamp
        );
        return true;
    }   
//********************************************************************** */
//********************************************************************** */


//********************************************************************** */
                        //funciones de usuarios
//********************************************************************** */
function investmentUser(
    uint256 _idHarvest,
    uint256 _treeNumber,
    uint256 _amount) 
    public returns(bool){
    
    //existe el cultivo ?
    require(
        IdDetailHarvest[_idHarvest].idHarvest == _idHarvest,
        "The Harves no exists"
        );
    
    require(
        isPaused(_idHarvest) == false,
        "The harvest is Pause"
        );

    require(
        IdDetailHarvest[currentIdHarvest].state == stateHarvest.RECEIVE_FUNDS,
        "The state from harvest is not RECEIVE_FUNDS"
        );

    // tiene fondos suficientes?
    require(
        USD.balanceOf(msg.sender)>= _amount,
        "Do not have the necessary funds of USD"
        );


    uint256 amountAndfee = getAmountAndFee(_amount);   
    require(
        IdDetailHarvest[_idHarvest].priceTree * _treeNumber >= amountAndfee, 
        "is not sending the value to execute the transaction"
        );

    USD.approve(address(this), _amount);
    
    


    


        
}

//********************************************************************** */
//********************************************************************** */

    //funciones de equipo

    //funciones de agricultores


    constructor(address usd) {
        usersTeam[msg.sender] = true;
        
        USD = IERC20(usd);
    }

}
