//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./IERC20.sol";

contract Agriculture {
    IERC20 public USD;

    uint256 private currentIdHarvest;
    uint256 private currentIdInvestment;

    // expresado en ETH => % * 1 ether / 100
    uint256 private feeTransaction;
    uint256 private totalFee;

    enum stateHarvest {
        CREATED,
        ANALYSIS,
        VALIDATED,
        RECEIVE_FUNDS,
        EXECUTION,
        FINALIZED
    }

    struct HarvestStruct {
        uint256 idHarvest;
        string nameHarves;
        uint256 treeNumber;
        uint256 harvestDays;
        bool renewal;
        uint256 salePrice;
        //precio por arbol
        uint256 priceTree;
        uint256 earningsTree;
       
        uint256 earningsDepositFarmer;
        bool pause;
        stateHarvest state;
        address farmer;
        //idInversion => idPlantacion
        mapping(uint256 => uint256) investmentHarvest;
        uint256[] listInvestment;
    }

    //idPlantacion => detallePlantacion
    mapping(uint256 => HarvestStruct) public IdDetailHarvest;
    //uint256[] public listHarvest;

    // agricultor(1) => cultivo(*)
    mapping(address => uint256[]) public FamerHarvest;

    struct InvestmentHarvest {
        uint256 idInvestment;
        uint256 idHarvest;
        uint256 treeNumber;
        uint256 valueInvestment;
        uint256 dateInvestment;
        address user;
    }
    //idInversion => detalleInversion
    mapping(uint256 => InvestmentHarvest) public IdInvestment;
    uint256[] private listInvestment;

    mapping(address => uint256[]) private UserInvestment;

    struct InvestmentTotalHarvest {
        uint256 treeSold;
        uint256 totalAmount;
    }
    mapping(uint256 => InvestmentTotalHarvest) public HarvestTotalInvestment;

    mapping(address => bool) public usersTeam;

    mapping(address => bool) public userFarmer;

    //********************************************************************************** */
    //                                 EVENT
    //********************************************************************************** */
    event AddUserFarmer(address team, address farmer, uint256 date);

    event AddUserTeam(address team, address newTeam, uint256 date);

    event DeletUserFarmer(address team, address farmer, uint256 date);

    event DeleteUserTeam(address team, address newTeam, uint256 date);

    event CrearteNewHarvest(address team, uint256 idHarvest, uint256 date);

    event AddUserInvestment(address user, uint256 idInvestment, uint256 date);

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

    event Pause(address team, uint256 idHarvest, bool isPause, uint256 date);

    event Unpause(address team, uint256 idHarvest, bool isPause, uint256 date);

    event SetFeeTransaction(address team, uint256 fee, uint256 date);

    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------

    modifier onlyTeam() {
        require(
            usersTeam[msg.sender] == true,
            "Exclusive function of the team"
        );
        _;
    }

    function getUserInvestment(address _user, uint256 _index)
        external
        view
        returns (uint256)
    {
        return UserInvestment[_user][_index];
    }

    function getLengthUserInvestment(address _user)
        external
        view
        returns (uint256)
    {
        return UserInvestment[_user].length;
    }

    function getIdInvestment(uint256 _idInvestment)
        external
        view
        returns (InvestmentHarvest memory)
    {
        return IdInvestment[_idInvestment];
    }

    function getIdInvesmentUserHarvest(uint256 _idHarvest)
        private
        view
        returns (uint256)
    {
        //return HarvestTotalInvestment[_idHarvest][msg.sender];
    }

    

    //Esta una cosecha pausada?
    function isPaused(uint256 _idHarvest) public view returns (bool) {
        return IdDetailHarvest[_idHarvest].pause;
    }

    //recibier en expresado en ETH
    function setFeeTransaction(uint256 _fee) private onlyTeam returns (bool) {
        feeTransaction = _fee;
        emit SetFeeTransaction(msg.sender, _fee, block.timestamp);
        return true;
    }

    function getFeeTransactionFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        uint256 currentTransactionFee = (_amount * feeTransaction) / 1 ether;
        //uint256 amoundAndPorcentage = _amount + currentTransactionFee;
        return currentTransactionFee;
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
    function getCurrentIdHarvest() external view returns (uint256) {
        return currentIdHarvest;
    }

    function getCurrentIdInvestment() external view returns (uint256) {
        return currentIdInvestment;
    }

    function increaseIdHarvest() private returns (bool) {
        currentIdHarvest += 1;
        return true;
    }

    function increaseIdInvestment() private returns (bool) {
        currentIdInvestment += 1;
        return true;
    }

    // relaciona una inversion con un usuario
    function addUserInvestment(address _user, uint256 _idInvestment)
        private
        onlyTeam
        returns (bool)
    {
        require(
            IdInvestment[_idInvestment].idHarvest == _idInvestment,
            "The investment no exists"
        );

        UserInvestment[_user].push(_idInvestment);

        emit AddUserInvestment(
            msg.sender,
            currentIdInvestment,
            block.timestamp
        );

        return true;
    }

    function getIdHarvestFarmer(uint256 _idHarvest, address _user)
        public
        view
        returns (uint256)
    {
       

        uint256 harvestReturn = 0;
        if (FamerHarvest[_user].length > 0) {
            for (uint256 i = 0; i < FamerHarvest[_user].length; i++) {
                uint256 idHarvest = FamerHarvest[_user][i];
                if (IdDetailHarvest[idHarvest].idHarvest == _idHarvest) {
                    harvestReturn = idHarvest;
                }
            }
        }

        return harvestReturn;
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

    function addTreeSoldHarvest(uint256 _idHarvest, uint256 _trees)
        private
        returns (bool)
    {
        require(
            IdDetailHarvest[_idHarvest].idHarvest == _idHarvest,
            "The Harves no exists"
        );

        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        HarvestTotalInvestment[_idHarvest].treeSold += _trees;

        return true;
    }

    // funcions faltaria hacer validaciones
    // crear un cultivo
    // cambiar la visibilidad
    function crearteNewHarvest(
        address _farmer,
        string memory _nameHArve,
        uint256 _treeNumber,
        uint256 _harvesDays,
        bool _renewal,
        uint256 _salePrice,
        uint256 _priceTree,
        uint256 _earningsTree
    ) public onlyTeam returns (bool) {
        //inicia desde 1

        IdDetailHarvest[currentIdHarvest].idHarvest = currentIdHarvest;
        IdDetailHarvest[currentIdHarvest].nameHarves = _nameHArve;
        IdDetailHarvest[currentIdHarvest].farmer = _farmer;
        IdDetailHarvest[currentIdHarvest].treeNumber = _treeNumber;
        IdDetailHarvest[currentIdHarvest].harvestDays = _harvesDays;
        IdDetailHarvest[currentIdHarvest].renewal = _renewal;
        IdDetailHarvest[currentIdHarvest].salePrice = _salePrice;
        IdDetailHarvest[currentIdHarvest].priceTree = _priceTree;
        IdDetailHarvest[currentIdHarvest].state = stateHarvest.CREATED;
        IdDetailHarvest[currentIdHarvest].pause = false;
        IdDetailHarvest[currentIdHarvest].earningsTree = _earningsTree;

        addFamerHarvest(_farmer, currentIdHarvest);

        increaseIdHarvest();

        emit CrearteNewHarvest(msg.sender, currentIdHarvest, block.timestamp);

        return true;
    }

    function earningsDepositFarmer(uint256 _idHarvest, uint256 _amount)
        public
        returns (bool)
    {
        require(userFarmer[msg.sender] == true, "The addres is not a farmer");

        uint256 idHarvest = getIdHarvestFarmer(_idHarvest, msg.sender);

        require(idHarvest > 0, "The harvest does not exists");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.FINALIZED,
            "The state from harvest is not FINALIZED"
        );

         require(
            USD.balanceOf(msg.sender) >= _amount,
            "Do not have the necessary funds of USD"
        );  
        
        uint256 treeSoldHarvest = HarvestTotalInvestment[_idHarvest].treeSold;


        uint256 earningsTree = IdDetailHarvest[_idHarvest].earningsTree;


        uint256 transactionFee = getFeeTransactionFee(
            treeSoldHarvest * earningsTree
        );

        uint256 totalAmountTransaction = (treeSoldHarvest * earningsTree) +
            transactionFee;             
      
        
        require(
            _amount >= totalAmountTransaction,
            "The amount does not equal the promised earnings"
        );

        USD.transferFrom(msg.sender, address(this), totalAmountTransaction);        


        totalFee += transactionFee;
  
        return true;
    }

    //************************************************************************************/
    //************************************************************************************/

    //************************************************************************************/
    //                             Funciones de cambio de estado
    //************************************************************************************/
    function changeStateHarvestToAnalysis(uint256 _idHarvest)
        external
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.CREATED,
            "The state from harvest is not CREATED"
        );

        IdDetailHarvest[_idHarvest].state = stateHarvest.ANALYSIS;

        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.ANALYSIS,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToValidated(uint256 _idHarvest)
        external
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.ANALYSIS,
            "The state from harvest is not ANALYSIS"
        );
        IdDetailHarvest[_idHarvest].state = stateHarvest.VALIDATED;

        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.VALIDATED,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToReceiveFunds(uint256 _idHarvest)
        external
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.VALIDATED,
            "The state from harvest is not VALIDATED"
        );

        IdDetailHarvest[_idHarvest].state = stateHarvest.RECEIVE_FUNDS;

        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.RECEIVE_FUNDS,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToExecution(uint256 _idHarvest)
        external
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.RECEIVE_FUNDS,
            "The state from harvest is not RECEIVE_FUNDS"
        );
        IdDetailHarvest[_idHarvest].state = stateHarvest.EXECUTION;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.EXECUTION,
            block.timestamp
        );
        return true;
    }

    function changeStateHarvestToFinalized(uint256 _idHarvest)
        external
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.EXECUTION,
            "The state from harvest is not EXECUTION"
        );
        IdDetailHarvest[_idHarvest].state = stateHarvest.FINALIZED;
        emit ChangeStateHarvest(
            msg.sender,
            _idHarvest,
            stateHarvest.FINALIZED,
            block.timestamp
        );
        return true;
    }

    //cambiar la visibilidad ??
    function pauseHarvest(uint256 _idHarvest) external onlyTeam returns (bool) {
        require(isPaused(_idHarvest) == false, "The harvest is Pause");
        IdDetailHarvest[_idHarvest].pause = true;

        emit Pause(msg.sender, _idHarvest, true, block.timestamp);
        return true;
    }

    function unPauseHArvest(uint256 _idHarvest)
        private
        onlyTeam
        returns (bool)
    {
        require(isPaused(_idHarvest) == true, "The harvest is not unPause");
        IdDetailHarvest[currentIdHarvest].pause = false;
        emit Unpause(msg.sender, _idHarvest, true, block.timestamp);
        return true;
    }

    //--------------------------------------------------------------------------------------
    //--------------------------------------------------------------------------------------

    //******************************************************************************* */
    //                          Funicones Inversiones
    //******************************************************************************* */

    //hay arboles por vender?
    function isTreesToSell(uint256 _idHarvest) private view returns (bool) {
        bool toSell = false;
        if (
            HarvestTotalInvestment[_idHarvest].treeSold <=
            IdDetailHarvest[_idHarvest].treeNumber
        ) {
            toSell = true;
        }
        return toSell;
    }

    function CreateInvestment(
        uint256 _idHarvest,
        uint256 _treeNumber,
        uint256 _amount,
        address _user
    ) private returns (bool) {
        IdInvestment[currentIdInvestment].idInvestment = currentIdInvestment;
        IdInvestment[currentIdInvestment].idHarvest = _idHarvest;
        IdInvestment[currentIdInvestment].treeNumber = _treeNumber;
        IdInvestment[currentIdInvestment].valueInvestment = _amount;
        IdInvestment[currentIdInvestment].dateInvestment = block.timestamp;
        IdInvestment[currentIdInvestment].user = _user;
        return true;
    }

    function IncreaseHarvestTotalInvestment(
        uint256 _idHarvest,
        uint256 _treeNumber,
        uint256 _valueOfTrees
    ) private returns (bool) {
        HarvestTotalInvestment[_idHarvest].treeSold += _treeNumber;
        HarvestTotalInvestment[_idHarvest].totalAmount += _valueOfTrees;
        return true;
    }

    //-------------------------------------------------------------------------------- */
    //-------------------------------------------------------------------------------- */

    //******************************************************************************** */
    //                          funciones de usuarios
    //******************************************************************************** */

    // El usuario tiene una inversion en un cultivo?
    function getIdInvestmentHarvestUser(uint256 _idHarvest, address _user)
        public
        view
        returns (uint256)
    {
        uint256 investmentReturn = 0;
        if (UserInvestment[_user].length > 0) {
            for (uint256 i = 0; i < UserInvestment[_user].length; i++) {
                uint256 idInvesment = UserInvestment[_user][i];
                if (IdInvestment[idInvesment].idHarvest == _idHarvest) {
                    investmentReturn = idInvesment;
                }
            }
        }

        return investmentReturn;
    }

    function invesmentCreateUserHarvest(
        uint256 _idHarvest,
        uint256 _treeNumber,
        uint256 _amount
    ) public returns (bool) {
        //existe el cultivo ?

        require(
            IdDetailHarvest[_idHarvest].idHarvest == _idHarvest,
            "The Harvest no exists"
        );

        require(_idHarvest > 0, "The Harvest not exists");

        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            isTreesToSell(_idHarvest),
            "There are no trees available to buy"
        );

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.RECEIVE_FUNDS,
            "The state from harvest is not RECEIVE_FUNDS"
        );

        // tiene fondos suficientes?
        require(
            USD.balanceOf(msg.sender) >= _amount,
            "Do not have the necessary funds of USD"
        );

        uint256 valueOfTrees = IdDetailHarvest[_idHarvest].priceTree *
            _treeNumber;

        uint256 fee = getFeeTransactionFee(valueOfTrees);

        require(
            (IdDetailHarvest[_idHarvest].priceTree * _treeNumber) + fee <=
                _amount,
            "Is not sending the value to execute the transaction"
        );

        USD.transferFrom(msg.sender, address(this), valueOfTrees);

        totalFee += fee;

        bool isCreateInvestmen = CreateInvestment(
            _idHarvest,
            _treeNumber,
            valueOfTrees,
            msg.sender
        );
        require(isCreateInvestmen, "Error creating investment");

        listInvestment.push(currentIdInvestment);
        UserInvestment[msg.sender].push(currentIdInvestment);

        //Actualizacion registro plantacion -- funcion ?
        IdDetailHarvest[_idHarvest].investmentHarvest[
            currentIdInvestment
        ] = _idHarvest;
        IdDetailHarvest[_idHarvest].listInvestment.push(currentIdInvestment);

        bool isIncrease = IncreaseHarvestTotalInvestment(
            _idHarvest,
            _treeNumber,
            valueOfTrees
        );

        increaseIdInvestment();

        require(isIncrease, "Error inverease total value of harvest");

        return true;
    }

    function invesmentUpdateUserHarvest(
        uint256 _idHarvest,
        uint256 _treeNumber,
        uint256 _amount
    ) public returns (bool) {
        uint256 idInvestmentHarvestUser = getIdInvestmentHarvestUser(
            _idHarvest,
            msg.sender
        );

        require(idInvestmentHarvestUser != 0, "The Investment does not exist");

        require(
            IdDetailHarvest[_idHarvest].idHarvest == _idHarvest,
            "The Harvest no exists"
        );

        require(_idHarvest > 0, "The Harvest not exists");

        require(isPaused(_idHarvest) == false, "The harvest is Pause");

        require(
            isTreesToSell(_idHarvest),
            "There are no trees available to buy"
        );

        require(
            IdDetailHarvest[_idHarvest].state == stateHarvest.RECEIVE_FUNDS,
            "The state from harvest is not RECEIVE_FUNDS"
        );

        // tiene fondos suficientes?
        require(
            USD.balanceOf(msg.sender) >= _amount,
            "Do not have the necessary funds of USD"
        );

        uint256 valueOfTrees = IdDetailHarvest[_idHarvest].priceTree *
            _treeNumber;

        uint256 fee = getFeeTransactionFee(valueOfTrees);

        require(
            (IdDetailHarvest[_idHarvest].priceTree * _treeNumber) + fee <=
                _amount,
            "Is not sending the value to execute the transaction"
        );

        USD.transferFrom(msg.sender, address(this), valueOfTrees);

        totalFee += fee;

        IdInvestment[idInvestmentHarvestUser].treeNumber += _treeNumber;
        IdInvestment[idInvestmentHarvestUser].valueInvestment += valueOfTrees;
        IdInvestment[idInvestmentHarvestUser].dateInvestment = block.timestamp;

        bool isIncrease = IncreaseHarvestTotalInvestment(
            _idHarvest,
            _treeNumber,
            valueOfTrees
        );

        require(isIncrease, "Error inverease total value of harvest");

        return true;
    }

    //-------------------------------------------------------------------------------- */
    //-------------------------------------------------------------------------------- */

    //funciones de equipo

    //********************************************************************** */
    //                          funciones de agricultores
    //********************************************************************** */

    //---------------------------------------------------------------------- */
    //---------------------------------------------------------------------- */

    constructor(address usd) {
        usersTeam[msg.sender] = true;

        USD = IERC20(usd);

        increaseIdHarvest();
        increaseIdInvestment();
    }
}
