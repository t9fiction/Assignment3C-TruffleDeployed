//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.4;

/* Please complete the ERC20 token with the following extensions;
1. Owner can transfer the ownership of the Token Contract.
2. Owner can approve or delegate anybody to manage the pricing of tokens.
3. Update pricing method to allow owner and approver to change the price of the token
4. Add the ability that Token Holder can return the Token and get back the Ether based on the current price.
*/

// ==========================================================================================================

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract AxyToken is ERC20{

    address _owner;
    uint public rate;
    uint private tokenCap = 2000000 * 100 ** 18;
    uint private deployedtime;
    address tokenAddress;
    mapping (address => bool) approvedUsers;
    mapping (address => uint) tokenHolders;
    uint boughtTokens;
    
  constructor() ERC20("axy", "AXY") {
        _mint(msg.sender, 1000000  );
        rate = 1;
        deployedtime =  block.timestamp;
        // IERC20 tcontract = IERC20(tokenAddress);
        _owner = msg.sender;
    }
    
      modifier etherValue {
      require( msg.value > 0);  
      _;
  }
  
    modifier _onlyOwner() {
    require(msg.sender == _owner);
    _;
}

modifier _onlyAllowed() {
    require(approvedUsers[msg.sender],"User not in the approvers list");
    _;
}
   // =============================================================================================================== //
   /* 1. Owner can transfer the ownership of the Token Contract. */
  
  function _transferOwnership(address _newOwner) internal _onlyOwner{
      _owner = _newOwner;
  }
  
  function newOwner(address new_Owner) public  _onlyOwner {
    require(new_Owner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(new_Owner);
}
   // =============================================================================================================== //
   /* 2. Owner can approve or delegate anybody to manage the pricing of tokens. */
   // __ Function to add addresses to the mapping___
    function _addApprover(address _user) public _onlyOwner {
      approvedUsers[_user] = true;
  }
  
    // __ Function to remove addresses to the mapping___
    function _removeApprover(address _user) public _onlyOwner {
      approvedUsers[_user] = false;
  }
   // =============================================================================================================== //
   /* 3. Update pricing method to allow owner and approver to change the price of the token*/
   // ___ user from mapping checked and if true then the rate can be change, else not____
    function pricing(uint _rate) public _onlyAllowed{
    rate = _rate ;
  }
  
  // =============================================================================================================== //
  /* 4. Add the ability that Token Holder can return the Token and get back the Ether based on the current price. */
  
  function buyTokens() payable external {
    require(ERC20.totalSupply() + msg.value * rate <= tokenCap && msg.value > 0 , "ERC20Capped: Token Cap exceeded");
    boughtTokens = msg.value * rate;
    _mint(msg.sender, boughtTokens );
    tokenHolders[msg.sender] += msg.value * rate;
  }
  

  function returnTokens(uint returned) payable external {
    require(returned > 0 && returned <= tokenHolders[msg.sender], "Token Wapsi Nishta");
    _transfer(msg.sender, address(this), (returned));
    payable(msg.sender).transfer(rate*returned);
    tokenHolders[msg.sender] -= msg.value * rate ;
  }
  
    // ____________________ Fallback ____________________
  
  fallback() external payable etherValue(){
      _mint(msg.sender, msg.value * rate * 10 ** 18);
  }

   receive() external payable{
    }
    
}