// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ClaimedToken(address indexed reciever, uint256 value);
}


contract OkeToken is IERC20 {
    using SafeMath for uint256;

    string public constant name = "OkeToken";
    string public constant symbol = "OKE";
    uint8 public constant decimals = 18;
    address payable public deployer;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;
    uint256 private constant claimTokenRate = 1000; // 0.001 ETH/OKE

    constructor() payable {
        deployer = payable(msg.sender);
        totalSupply_ = 1000000 * 10**decimals;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);

        uint256 amountToBurn = calculateBurn(numTokens);
        uint256 totalAmount = numTokens + amountToBurn;
        require(totalAmount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        burn(msg.sender, numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

        
    function buyToken(address reciever) public payable returns (bool){
        require(msg.value >= 0, "You cannot mint with zero ETH");
        (bool success, ) = deployer.call{value: msg.value}("");
        require(success, "Failed to send money");
        uint numTokens = (msg.value * claimTokenRate);
        balances[reciever] = balances[reciever].add(numTokens);
        totalSupply_ = totalSupply_.sub(numTokens);
        totalSupply_ = totalSupply_.add(numTokens);
        emit ClaimedToken(reciever, msg.value);
        return true;
    }

    function burn(address account, uint256 burnAmount) internal {
        require(account != address(0), "wrong EOA");
        require(burnAmount <= balances[account], "insufficient amount to burn");

        totalSupply_ = totalSupply_.sub(burnAmount);
        balances[account] = balances[account].sub(burnAmount);
        emit Transfer(account, address(0), burnAmount);

    }

    function calculateBurn(uint256 transferAmount) internal pure returns (uint256) {
      uint256 burnPercentage = 10; // 10%

      // Calculate the burn amount using simple percentage calculation
      uint256 burnAmount = (transferAmount * burnPercentage) / 100;

      // Ensure burn amount doesn't exceed transfer amount
      burnAmount = burnAmount > transferAmount ? transferAmount : burnAmount;
      return burnAmount;
    }
    

}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

}
