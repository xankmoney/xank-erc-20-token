pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */

 contract ERC20PartialLock is ERC20, Ownable, Pausable {

   using SafeMath for uint256;
   mapping (address => uint256) private _locked;
   mapping (address => uint256) private _totalAllowed;

    function _lock(address account, uint256 value) internal {
        require(account != address(0));
        require(balanceOf(account) >= _locked[account].add(value));
        _locked[account] = _locked[account].add(value);
    }

     function _release(address account, uint256 value) internal {
         require(account != address(0));
         _locked[account] = _locked[account].sub(value);
     }

     function lockedOf(address owner) public view returns (uint256) {
        return _locked[owner];
    }


    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        require(balanceOf(msg.sender).sub(_locked[msg.sender]) >= value);
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        require(balanceOf(msg.sender).sub(_totalAllowed[msg.sender]).sub(_locked[msg.sender]) >= value);
        _totalAllowed[msg.sender] = _totalAllowed[msg.sender].add(value);
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        require(balanceOf(msg.sender).sub(_totalAllowed[msg.sender]).sub(_locked[msg.sender]) >= addedValue);
        _totalAllowed[msg.sender] = _totalAllowed[msg.sender].add(addedValue);
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        _totalAllowed[msg.sender] = _totalAllowed[msg.sender].sub(subtractedValue);
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function Lock(address lockee, uint256 value) public onlyOwner returns (bool) {
      _lock(lockee, value);
      return true;
    }

    function Release(address lockee, uint256 value) public onlyOwner returns (bool) {
      _release(lockee, value);
      return true;
    }

    function Suicide() public onlyOwner returns (bool) {
      selfdestruct(address(uint160(msg.sender)));
      return true;
    }
}
