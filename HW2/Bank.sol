pragma solidity ^0.6.0;

contract bank1 {
    
    bank2 clone = new bank2();
    
    mapping(address => uint256) public balances;//地址：餘額
    mapping(string => address) public students; //學號：地址
    
    //紀錄每筆交易的發起者、接收者、金額、時間戳記
    address[] public from_;
    address[] public to_;
    uint256[] public money;
    uint256[] public time;
    
    address payable public owner;
    constructor() public payable {
        owner = msg.sender;
    }
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        
        from_.push(msg.sender);
        to_.push(address(this));
        money.push(msg.value);
        time.push(block.timestamp);
    }
    
    function withdraw(uint256 amount) public payable {
        require(balances[msg.sender] >= amount, "You don't have enough money.");
        
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
        
        from_.push(address(this));
        to_.push(msg.sender);
        money.push(amount);
        time.push(block.timestamp);
    }
    
    function transfer(uint256 amount, address target) public payable {
        require(balances[msg.sender] >= amount, "You don't have enough money.");
        balances[msg.sender] -= amount;
        balances[target] += amount;
        
        from_.push(msg.sender);
        to_.push(target);
        money.push(amount);
        time.push(block.timestamp);
    }
    
    function getBalance() external view returns(uint256) {
        return balances[msg.sender];
    }
    
    function getBankBalance() external view returns(uint256) {
        require(msg.sender == owner, "You are not the owner. who are you?");
        return address(this).balance;
    }
    
    function enroll(string calldata studentid) external {
        students[studentid] = msg.sender;
    }
    
    function check_tx_detail(uint256 index) external view returns(address,address,uint256,uint256) {
        return(from_[index],to_[index],money[index],time[index]);
    }
    
    fallback() external {
        require(owner == msg.sender, "Permission denied");
        selfdestruct(owner);
    }
    
    //如果有人把錢轉到合約，但是沒有call任何function的話，就把錢轉給owner
    receive() external payable {
        owner.transfer(msg.value);
        
        from_.push(msg.sender);
        to_.push(owner);
        money.push(msg.value);
        time.push(block.timestamp);
    }
    
    //因為students跟balances這兩個mapping紀錄的資料是有關連的
    //所以我想說設計一個function丟學號進去，可以回傳其銀行餘額
    //跟getBalance的差別就在，只要知道別人的學號，就能看別人的銀行餘額
    //但是getBalance只能看自己的餘額
    function from_studentID_getBalance(string calldata studentid) external view returns(uint256){
        //這邊也可以加一行require，變成只有owner可以查看其他人的銀行餘額
        //require(msg.sender == owner, "Permission denied")
        return balances[students[studentid]];
    }
    
    //額外創建一個合約bank2，本來希望兩個銀行之間的錢能夠互轉
    //但是不知道要如何轉錢給bank2
    //如果我用address(clone).transfer(msg.value)
    //會報錯說address要是payable才能轉帳
    function get_Bank2_Balance() external view returns(uint256) {
        return address(clone).balance;
    }
}

contract bank2 {
}
