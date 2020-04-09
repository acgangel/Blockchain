pragma solidity ^0.6.0;

contract Bank {
    
   
    mapping(string => address) public students; //學號映射到地址
    mapping(address => uint256) public balances; //地址映射到存款金額
    mapping (address => bool) public blacklist;// 黑名單客戶(名單僅擁有者可設定，遭黑名單者禁止轉帳、提領、捐款等行為)
    address payable public owner; //銀行的擁有者
    
    //設定owner為創立合約的人
    constructor () public payable{
        owner = msg.sender;
    }
    
    //透過students把學號映射到使用者的地址
    function enroll(string memory studentId, address studentAddress) public {
        students[studentId] = studentAddress;
    }
    
    
    //可以讓使用者call這個函數把錢存進合約地址，並且在balances中紀錄使用者的帳戶金額
    function deposit() public payable returns (uint256) {
        require(!blacklist[msg.sender], "You do not have permission.");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        return balances[msg.sender];
    }

    //可以讓使用者從合約提錢，這邊需要去確認合約裡的餘額 >= 想提的金額 function withdraw(金額)
     function withdraw(uint256 amount) public payable returns (uint256) {
         require(!blacklist[msg.sender], "You do not have permission.");
         if (balances[msg.sender]>= amount) {
             balances[msg.sender] = balances[msg.sender] - amount;
             msg.sender.transfer(amount);
        }
        return balances[msg.sender];
    }
    
    //可以讓使用者從合約轉帳給某個地址，這邊需要去確認合約裡的餘額 >= 想轉的金額
    //實現的是銀行內部轉帳，也就是說如果轉帳成功balances的目標地址會增加轉帳金額
    function transfer(uint256 transferamount, address studentAddress) public payable{
        require(balances[msg.sender]>= transferamount , "Your balances is not enough to transfer.");
        require(!blacklist[msg.sender], "You do not have permission.");
        balances[msg.sender] = balances[msg.sender] - transferamount;
        balances[studentAddress] = balances[studentAddress] + transferamount;
    }
    

    //從balances回傳使用者的銀行帳戶餘額
    function getBalance() public view returns (uint256) {
        require(!blacklist[msg.sender], "You do not have permission.");
        return balances[msg.sender];
    }

    
    //回傳銀行合約的所有餘額，設定為只有owner才能呼叫成功
    function getBankBalance() public view returns(uint256){
        require(!blacklist[msg.sender], "You do not have permission.");
        require(owner == msg.sender, "Permission denied. You are not the owner of the bank.");
        return address(this).balance;
    }
    
    //當觸發fallback時，檢查觸發者是否為owner，是則自殺合約，把合約剩餘的錢轉給owner
    fallback () external {
      require(owner == msg.sender, "Permission denied. You are not the owner of the bank.");
      selfdestruct(owner);
    }
    
    //他人捐款給銀行擁有者帳戶，銀行擁有者不能捐款給自己
    function donate() public payable {
        require(!blacklist[msg.sender], "You do not have permission.");
        require(msg.sender != owner, "Permission denied. Owner of the bank can't donate to itself.");
        balances[owner]=balances[owner] + msg.value;
    }
    
    // 加入黑名單
    function addBlacklist(address studentAddress) public {
        require(msg.sender == owner, "Permission denied. Only owner of the bank has permission.");
        blacklist[studentAddress] = true;
    }
    
    // 從黑名單移除
    function removeBlacklist(address studentAddress) public {
        require(msg.sender == owner, "Permission denied. Only owner of the bank has permission.");
        blacklist[studentAddress] = false;
    }
  

}