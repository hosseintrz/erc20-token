pragma solidity ^0.8.0;

contract SafeMath {
 
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 
interface ERC20Interface {

    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract HTCToken is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    constructor() public {
        symbol = "HTC";
        name = "HOSSEINTRZ Coin";
        decimals = 10;
        _totalSupply = 1000000000000;
        balances[msg.sender] = _totalSupply;
    }
 
    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }
 
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens, "not enough balance");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
 
    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(tokens <= balances[from], "not enough balance");
        require(tokens <= allowed[from][msg.sender], "you can't access this amount of tokens");
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
 
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}


contract SGB is ERC20Interface, SafeMath {
    address public chairman;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
 
    uint public bricks;
    uint public blocks;
    uint public stones;
    uint public cement;

    uint required_bricks;
    uint required_blocks;
    uint required_stones;
    uint required_cement;
    uint token_gen_rate;

    address[] employees;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    modifier onlyChairman{
        require(
            msg.sender == chairman,
            "only chairman can execute this function"
        );
        _;
    }

    constructor(uint _brick, uint _block, uint _stone, uint _cement, uint _token) public {
        chairman = msg.sender;
        symbol = "SGB";
        name = "SGB";
        decimals = 10;
        _totalSupply = 0;
        balances[msg.sender] = _totalSupply;
        required_bricks = _brick;
        required_blocks = _block;
        required_stones = _stone;
        required_cement = _cement;
        token_gen_rate = _token;
    
    
        bricks = 0;
        blocks = 0;
        stones = 0;
        cement = 0;
    }

    function updateProductions(uint _bricks, uint _blocks, uint _stones, uint _cement) public onlyChairman{
        bricks = safeAdd(bricks, _bricks);
        blocks = safeAdd(blocks, _blocks);
        stones = safeAdd(stones, _stones);
        cement = safeAdd(cement, _cement);
    }

    modifier sufficient_resources{
        require(bricks >= required_bricks, "insufficient bricks");
        require(blocks >= required_blocks, "insufficient blocks");
        require(stones >= required_stones, "insufficient stones");
        require(cement >= required_cement, "insufficient cement");
        _;
    }

    function generate_tokens() public sufficient_resources onlyChairman returns (uint256){
        uint256 generated_tokens = 0;
        while ((bricks >= required_bricks) && 
            (blocks >= required_blocks) &&
            (stones >= required_stones) && 
            (cement >= required_cement)
        ){
            bricks = safeSub(bricks, required_bricks);
            blocks = safeSub(blocks, required_blocks);
            stones = safeSub(stones, required_stones);
            cement = safeSub(cement, required_cement);
            generated_tokens += token_gen_rate;
        }
        add_supply(generated_tokens);
        return generated_tokens;
    }

    function add_supply(uint256 tokenCount) internal {
        _totalSupply = safeAdd(_totalSupply, tokenCount);
        balances[msg.sender] = tokenCount;
    }

    function add_employees(address[] memory employees_addr) public onlyChairman {
        for(uint i = 0; i < employees_addr.length; i++){
            address addr = employees_addr[i];
            employees.push(addr);
        }
    }
    function pay_employees() public onlyChairman returns (uint) {
        uint payable_balance = balances[msg.sender];
        require(payable_balance > 0, "no token supply");
        uint token_share =  payable_balance / employees.length;
        for(uint i = 0; i < employees.length; i++){
            transfer(employees[i], token_share);
        }
        return token_share;
    }


 
    function totalSupply() public override view returns (uint) {
        return _totalSupply;
    }
 
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens, "not enough balance");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
 
    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(tokens <= balances[from], "not enough balance");
        require(tokens <= allowed[from][msg.sender], "you can't access this amount of tokens");
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
 
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}