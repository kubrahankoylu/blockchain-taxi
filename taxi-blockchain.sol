pragma solidity >=0.4.22 <0.6.0;
contract Project{
    address manager;
    uint balance;
    uint taxiFee;
    uint cost;
    uint profit;
    uint ownProfit;
    uint fixExpenses = 10;
    uint time = now;
    uint expenseTime = now;
    address carId;
    uint year = 60;
    address[] offerList;
    bool check = true;
    bool state = true;

    struct proposedCars{
        address carId;
        uint price;
        uint offerTime;
    }
    struct purchaseCars{
        address carId;
        uint price;
        uint offerTime;
        uint appState;
    }
    struct user{
        address payable id;
        uint money;
    }
    struct driver{
        address payable id;
        uint money;
        uint time;
        uint feeTime;
    }
    struct dealer{
        address payable id;
        uint money;
    }
    user[] participants;
    driver taxiDriver;
    dealer carDealer;
    proposedCars proposedCar;
    purchaseCars purchaseCar;
    
    constructor() public{
        manager = msg.sender; 
        cost = 0 ether;
        balance = 0 ether;
    }
    
    function joinFunc()public payable{
        require( msg.value >= 100 ether, "Fee is not enough to join.");
        balance += msg.value;
        cost += msg.value;
        user memory participant = user({id: msg.sender, money:0 ether});
        participants.push(participant);
    }
    
    function SetCarDealer(address payable input) public returns(address carDeal){
        require(msg.sender == address(manager), "Sender is not authorized.");
        carDealer = dealer({id: input, money:0 ether});
        return carDealer.id;
    }
    
    function CarPropose(address _id, uint _price, uint _time)public {
        require( msg.sender == carDealer.id, "Sender is not authorized.");
        proposedCar = proposedCars({carId: _id, price: _price, offerTime:now+_time});
    }
    
    function PurchaseCar() public payable {
        require(msg.sender == manager, "Sender is not authorized.");
        if(proposedCar.offerTime >= now){
            if(balance >= proposedCar.price && address(this).balance >= proposedCar.price){
                balance -= proposedCar.price;
                carDealer.id.transfer(proposedCar.price);
            }
        }
    }
    
    function PurchasePropose() public{
        if(msg.sender == carDealer.id){
            purchaseCar = purchaseCars({carId : proposedCar.carId, price: proposedCar.price, offerTime: proposedCar.offerTime, appState: 0});
        }
    }
    
    function ApproveSellProposal() public{
        for(uint j=0 ; j<participants.length ; j++){
            if(msg.sender == offerList[j]){
                break;
            }
            purchaseCar.appState += 1;
            offerList.push(msg.sender);
        }
    }
    
    function SellCar(address) public {
        require(msg.sender == carDealer.id, "Sender is not authorized.");
        if(proposedCar.offerTime >= now){
            if( purchaseCar.appState > uint (participants.length/2)){
                carDealer.money -= proposedCar.price;
            }
        }
        
    }
    
    function SetDriver(address payable input) public payable returns(address id) {
        require(msg.sender == manager, "Sender is not authorized.");
        taxiDriver = driver({id: address(input), money:0, time:now, feeTime: now});
        return taxiDriver.id;
        
    }
    
    function PaySalary() public returns(uint money){
        require(msg.sender == manager, "Sender is not authorized.");
        if(now-taxiDriver.feeTime >= (year/12)){
            check = true;
        }
        if(((now - taxiDriver.time) % (year/12)) <(year/12)){
            if(check == true){
                if((((now-taxiDriver.feeTime)% (year/12) )<(year/12)) && (((now-taxiDriver.feeTime)%(year/12))!= 0)){
                    taxiDriver.money += (((now - taxiDriver.feeTime) / (year/12)) + 1 ) * 10 ether;
                    balance -= (((now - taxiDriver.feeTime) / (year/12)) + 1 ) * 10 ether;
                    taxiDriver.feeTime = now;
                    check =false;
                }
                else{
                    taxiDriver.money += ((now - taxiDriver.feeTime) / (year/12)) * 10 ether;
                    balance -= taxiDriver.money += ((now - taxiDriver.feeTime) / (year/12)) * 10 ether;
                    taxiDriver.feeTime = now;
                    check =false;
                }
            }
        }
        return taxiDriver.money;
    }
    
    function GetSalary() public payable returns(uint money){
        if(msg.sender == taxiDriver.id){
            if(address(this).balance >= taxiDriver.money){
                address payable someone = msg.sender;
                someone.transfer(taxiDriver.money);
                taxiDriver.money = 0;
            }
        }
        return taxiDriver.money;
    }
    
    function CarExpenses() public{
        require(msg.sender == manager, "Sender is not authorized.");
        if( (now - expenseTime) >= (year/2)){
            balance -= fixExpenses;
            expenseTime = now;
        }
    }
    
    function PayDividend(address) public{
        require(msg.sender == manager, "Sender is not authorized.");
        profit = balance-cost;
        taxiFee = taxiDriver.money;
        ownProfit = profit / participants.length;
        if((now - time) <= (year / 2)){
            for ( uint temp = 0 ; temp < participants.length ; temp ++){
                balance -= profit;
            }
        }
        
    }
    
    function GetCharge() public{
        balance +=50 ether;
    }
    
    function GetDividend() public payable{
        for(uint temp = 0 ; temp<participants.length ; temp++){
            if(msg.sender == participants[temp].id){
                participants[temp].id.transfer(ownProfit);
            }
        }
        
    }

}