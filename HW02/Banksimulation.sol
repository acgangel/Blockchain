pragma solidity ^0.6.0;

contract Bank {
    
   
    mapping(string => address) public students; //學號映射到地址
    mapping(address => uint256) public balances; //地址映射到存款金額
    mapping (address => bool) public blacklist;// 黑名單客戶(名單僅擁有者可設定，遭黑名單者禁止轉帳、提領、捐款等行為)
    address payable public owner; //銀行的擁有者(owner)
    
    //owner為創立合約者
    constructor () public payable{
        owner = msg.sender;
    }
    
    //學號映射到使用者地址
    function enroll(string memory studentId, address studentAddress) public {
        students[studentId] = studentAddress;
    }
    
    
    //將錢存進合約地址，並在balances中紀錄使用者的帳戶金額
    function deposit() public payable returns (uint256) {
        require(!blacklist[msg.sender], "You do not have permission.");
        balances[msg.sender] = balances[msg.sender] + msg.value;
        return balances[msg.sender];
    }

    //提領，並確認合約裡的餘額>=提領金額
     function withdraw(uint256 amount) public payable returns (uint256) {
         require(!blacklist[msg.sender], "You do not have permission.");
         if (balances[msg.sender]>= amount) {
             balances[msg.sender] = balances[msg.sender] - amount;
             msg.sender.transfer(amount);
        }
        return balances[msg.sender];
    }
    
    //銀行內部轉帳，確認餘額 >= 轉帳金額 (轉帳成功後目標地址餘額會增加)
    function transfer(uint256 transferamount, address studentAddress) public payable{
        require(balances[msg.sender]>= transferamount , "Your balances is not enough to transfer.");
        require(!blacklist[msg.sender], "You do not have permission.");
        balances[msg.sender] = balances[msg.sender] - transferamount;
        balances[studentAddress] = balances[studentAddress] + transferamount;
    }
    

    //回傳使用者銀行帳戶餘額
    function getBalance() public view returns (uint256) {
        require(!blacklist[msg.sender], "You do not have permission.");
        return balances[msg.sender];
    }

    
    //回傳銀行合約所有餘額(owner only)
    function getBankBalance() public view returns(uint256){
        require(!blacklist[msg.sender], "You do not have permission.");
        require(owner == msg.sender, "Permission denied. You are not the owner of the bank.");
        return address(this).balance;
    }
    

    //他人捐款給owner，owner不能捐獻給自己
    function donate() public payable {
        require(!blacklist[msg.sender], "You do not have permission.");
        require(msg.sender != owner, "Permission denied. Owner of the bank can't donate to itself.");
        balances[owner]=balances[owner] + msg.value;
    }
    
    // 加入黑名單(owner only)
    function addBlacklist(address studentAddress) public {
        require(msg.sender == owner, "Permission denied. Only owner of the bank has permission.");
        blacklist[studentAddress] = true;
    }
    
    // 從黑名單移除(owner only)
    function removeBlacklist(address studentAddress) public {
        require(msg.sender == owner, "Permission denied. Only owner of the bank has permission.");
        blacklist[studentAddress] = false;
    }

        //觸發fallback時自殺合約並將錢轉給owner(owner only)
    fallback () external {
      require(owner == msg.sender, "Permission denied. You are not the owner of the bank.");
      selfdestruct(owner);
    }
    

}