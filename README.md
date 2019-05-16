# XANK Token (LXANK)
XANK-issued ERC20 public smart contract repository.

https://xank.io

The whitepaper can be found [here](http://paper.xank.io/).

## Address

Interaction with XANK is done at the address at `0x68f8b2e7b1a5841724e614758a56ade0482f077e`. See
https://etherscan.io/token/0x68f8b2e7b1a5841724e614758a56ade0482f077e for live on-chain details.

## Contract Specification

XANK (LXANK) is an ERC20 token that is Centrally Minted and Burned and Locked by XANK

### ERC20 Token

The public interface of XANK is the ERC20 interface
specified by [EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md).

- `name()`
- `symbol()`
- `decimals()`
- `totalSupply()`
- `balanceOf(address who)`
- `transfer(address to, uint256 value)`
- `approve(address spender, uint256 value)`
- `allowance(address owner, address spender)`
- `transferFrom(address from, address to, uint256 value)`

And the usual events.

- `event Transfer(address indexed from, address indexed to, uint256 value)`
- `event Approval(address indexed owner, address indexed spender, uint256 value)`

Typical interaction with the contract will use `transfer` to move the token as payment.
Additionally, a pattern involving `approve` and `transferFrom` can be used to allow another 
address to move tokens from your address to a third party without the need for the middleperson 
to custody the tokens, such as in the 0x protocol. 

#### Warning about ERC20 approve front-running

There is a well known gotcha involving the ERC20 `approve` method. The problem occurs when the owner decides
to change the allowance of a spender that already has an allowance. If the spender sends a `transferFrom` 
transaction at a similar time that the owner sends the new `approve` transaction
and the `transferFrom` by the spender goes through first, then the spender gets to use the 
original allowance, and also get approved for the intended new allowance.

The recommended mitigation in cases where the owner does not trust the spender is to
first set the allowance to zero before setting it to a new amount, checking that the 
allowance was not spent before sending the new approval transaction. Note, however, that any 
allowance change is subject to front-running, which is as simple as watching the 
mempool for certain transactions and then offering a higher gas price to get another 
transaction mined onto the blockchain more quickly.

### Pausing the contract

In the event of a critical security threat, XANK has the ability to pause transfers
and approvals of the XANK token. The simple model for pausing transfers following OpenZeppelin's
[Pausable](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/5daaf60d11ee2075260d0f3adfb22b1c536db983/contracts/lifecycle/Pausable.sol).
