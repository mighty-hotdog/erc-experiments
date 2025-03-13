# ERC223

## Goals
ERC223 aims to:
1. save gas by reducing ERC20's 2 txns (ie: approve() and transferFrom()) into 1
2. avoid ERC20 tokens getting stuck in non-compatible contracts (when they get sent via transfer())

## ERC20 vs ERC223

### sender sends ERC20 tokens to receiver #################################################
#### Method 1 - approve() and transferFrom()
steps
1. sender calls approve() on token to grant allowance to receiver
2. (assume) receiver calls transferFrom() on token to transfer tokens from sender to self
   can possibly happen only if receiver is a contract
   EOAs do not usually make function calls
problems
1. need at least 2 calls to complete single token transfer
2. receiver doesn't know if, who, how much, when granted allowance
   => need some way to inform receiver so it can proceed to call transferFrom()
3. if receiver is a contract, it has no way to perform any action upon receiving the tokens

#### Method 2 - transfer()
steps
1. sender calls transfer() on token to directly send tokens to receiver
problems
1. receiver doesn't know if, who, how much, when tokens sent to it
2. if receiver is a contract, it has no way to perform any action upon receiving the tokens
3. if receiver is a contract that isn't ERC20 compatible, transfer() still succeeds, but the
   sent tokens are now stuck on it

### sender sends ERC223 tokens to receiver ################################################
#### Only 1 method - transfer(), but note that ERC223 mandates 2 versions of this function
steps
1. sender calls transfer() on token to directly send tokens to receiver
2. transfer() function:
   a. transfers tokens from sender to receiver (just like ERC20 transfer())
   b. if receiver is a contract, calls tokenReceived() on receiver
      reverts if receiver is a contract but doesn't implement tokenReceived(), ie: non ERC223 compatible
   c. emits Transfer event (similiar to ERC20 Transfer event but with additional data field)

## Comments
ERC223, while solving some important ERC20 problems, seems both badly designed and badly written.
1. ERC223 is not backward compatible with ERC20.
   Can't work with existing ERC20 contracts, of which there are many:
   a. Can't send ERC223 tokens to existing ERC20 contracts - the ERC223 transfer() will revert.
   b. Existing ERC20 contracts can send ERC20 tokens to ERC223 contracts, but they cannot retrieve these
      sent tokens back from the ERC223 receiver contract.
1. ERC223 design seems technically inconsistent/incongruent
   Defines its own transfer() function with an extra data field which breaks ERC20, and then
   introduces a 2nd version of transfer() w/o the data field for compatibility, which ALSO breaks
   ERC20 (lol!).
2. The ERC223 doc is confusing to read, and contains dubious examples that suggests even more
   confusion in author's thinking.

## ERC223 Adoption
Tiny and stagnant since 2017 when 1st introduced.