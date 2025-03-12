// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";
import {ERC20Mintable} from "./ERC20Mintable.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {Pausable} from "./Pausable.sol";

/**
 * @title   ERC20Wrapper
 *          A wrapper for ERC20 tokens.
 * @author  @mighty_hotdog
 *          created 2025-03-12
 * @dev     This contract allows users to deposit/withdraw an underlying ERC20 token, and get back
 *          a matching number of a "wrapped" ERC20 token.
 *
 * @dev     Word of caution to any developer who decides to use this code!!!
 *
 *          In theory:
 *          1. total supply of deposited underlying tokens == total supply of wrapped tokens.
 *          2. user balance of wrapped tokens == wrapped token contract balance of deposited underlying tokens
 *
 *          However since for the 2 tokens here, each has its own methods that can modify these values
 *          independently of the other, the 2 conditions above may not be preserved.
 *          Haven't found a way to protect them yet.
 */
abstract contract ERC20Wrapper is ERC20Core, ERC20Mintable, ERC20Burnable, Pausable {
    event ERC20Wrapper_DepositedUnderlyingTokens(uint256 indexed _value);
    event ERC20Wrapper_WithdrawnUnderlyingTokens(uint256 indexed _value);

    address private immutable _underlyingToken;

    /**
     * @notice  constructor()
     *          Checks if underlying token is valid, then sets it.
     * @param   underlyingToken_        underlying token contract address
     * @param   maxWrappedTokenSupply_  max # of wrapped tokens
     * @dev     The test logic is shifted to _testIfUnderlyingTokenIsValid() function to allow overriding
     *          if desired.
     * @dev     Reverts if underlyingToken_ == address(0).
     * @dev     Reverts if underlyingToken_ == address(this).
     * @dev     Reverts if underlyingToken_ is not ERC20.
     */
    constructor(address underlyingToken_, uint256 maxWrappedTokenSupply_) ERC20Mintable(maxWrappedTokenSupply_) {
        _testIfUnderlyingTokenIsValid(underlyingToken_);
        _underlyingToken = underlyingToken_;
    }

    /**
     * @notice  underlying()
     *          Returns address of underlying token.
     * @dev     This is a getter function that never reverts.
     */
    function underlying() public view virtual returns (address) {
        return _underlyingToken;
    }

    /**
     * @notice  deposit()
     *          Allows caller to deposit some underlying tokens and get back matching amount
     *          of wrapped tokens.
     * @param   _value      amount of underlying tokens caller wishes to deposit
     * @dev     Refer to _deposit().
     */
    function deposit(uint256 _value) public virtual pausable {
        _deposit(_value, true);
    }

    /**
     * @notice  depositFor()
     *          Allows caller to deposit some underlying tokens and get matching amount of
     *          wrapped tokens deposited to a specified recipient.
     * @param   _to         recipient address to deposit wrapped tokens to
     * @param   _value      amount of underlying tokens caller wishes to deposit
     * @dev     Refer to _depositFor().
     */
    function depositFor(address _to, uint256 _value) public virtual pausable {
        _depositFor(_to, _value, true);
    }

    /**
     * @notice  withdraw()
     *          Allows caller to burn some wrapped tokens and get back matching amount of
     *          underlying tokens.
     * @dev     Refer to _withdraw().
     */
    function withdraw(uint256 _value) public virtual pausable {
        _withdraw(_value, true);
    }

    /**
     * @notice  withdrawTo()
     *          Allows caller to burn some wrapped tokens and get matching amount of
     *          underlying tokens deposited to a specified recipient.
     */
    function withdrawTo(address _to, uint256 _value) public virtual pausable {
        _withdrawTo(_to, _value, true);
    }

    /**
     * @notice  isContract()
     *          Generic function that tests if an address contains code, ie: is a contract.
     * @dev     Uses assembly.
     * @dev     Never reverts.
     */
    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @notice  isERC20()
     *          Tests if an address is an ERC20 token contract.
     * @dev     This test is certainly NOT foolproof as it tests for the existence of only
     *          3 of the view functions specified in the ERC20 standard.
     * @dev     Never reverts.
     */
    function isERC20(address addr) public view returns (bool) {
        if (isContract(addr)) {
            try ERC20Core(addr).totalSupply() returns (uint256) {
                try ERC20Core(addr).balanceOf(address(this)) returns (uint256) {
                    try ERC20Core(addr).allowance(msg.sender, address(this)) returns (uint256) {
                        return true;
                    } catch {return false;}
                } catch {return false;}
            } catch {return false;}
        }
        return false;
    }

    /**
     * @notice  _testIfUnderlyingTokenIsValid()
     *          Tests the address input provided to the constructor if it is an invalid underlying token.
     * @param   token   address of supposedly an underlying token
     * @dev     Reverts if token == address(0).
     * @dev     Reverts if token == address(this).
     * @dev     Reverts if token != an ERC20 token.
     */
    function _testIfUnderlyingTokenIsValid(address token) internal view virtual {
        if (token == address(0)) {
            revert("ERC20Wrapper: invalid underlying token address(0)");
        }
        if (token == address(this)) {
            revert("ERC20Wrapper: underlying token cannot have same address as the wrapped token");
        }
        if (!isERC20(token)) {
            revert("ERC20Wrapper: underlying token is not an ERC20 contract");
        }
    }

    /**
     * @notice  _deposit()
     *          Contains the logic for the public function deposit().
     * @param   _value      amount of underlying tokens caller wishes to deposit
     * @param   emitEvent   flag to control whether to emit deposit event
     */
    function _deposit(uint256 _value, bool emitEvent) internal virtual {
        // Depositing to self creates a malicious circular loop logic that destroys contract
        //  viability, hence this check is performed here as part of the "core" logic for this
        //  contract.
        if (msg.sender == address(this)) {
            revert("ERC20Wrapper: wrapped token cannot deposit to self");
        }

        // Step 1: Caller transfers underlying token from self to ERC20Wrapper.

        // Basically msg.sender is the caller who calls deposit() on the ERC20Wrapper
        //  contract.
        //      ie: msg.sender <<calls>> ERC20Wrapper.deposit()

        // From within deposit(), ERC20Wrapper (ie: "this") calls transferFrom() on the
        //  underlyingToken contract to transfer underlying tokens from msg.sender to
        //  itself.
        //      ie: ERC20Wrapper <<calls>> underlyingToken.transferFrom()
        // This means ERC20Wrapper is the spender that msg.sender needs to approve 1st with an
        //  appropriate allowance of underlying tokens.
        ERC20Core(underlying()).transferFrom(msg.sender, address(this), _value);
        if (emitEvent) {
            emit ERC20Wrapper_DepositedUnderlyingTokens(_value);
        }

        // Step 2: Caller mints matching amount of wrapped tokens to self.

        // Since mint() is in the same contract as deposit(), its caller here remains the
        //  same - msg.sender. So basically the caller (ie: msg.sender) calls mint() on the
        //  ERC20Wrapper contract to mint ERC20Wrapper wrapped tokens to self.
        //      ie: msg.sender <<calls>> ERC20Wrapper.mint()
        mint(msg.sender, _value);
    }

    /**
     * @notice  _depositFor()
     *          Contains the logic for the public function depositFor().
     * @param   _to         recipient address to deposit wrapped tokens to
     * @param   _value      amount of underlying tokens caller wishes to deposit
     * @param   emitEvent   flag to control whether to emit deposit event
     */
    function _depositFor(address _to, uint256 _value, bool emitEvent) internal virtual {
        // Depositing to self or minting to self creates a malicious circular loop logic that
        //  destroys contract viability, hence these 2 checks are performed here as part of the
        //  "core" logic for this contract.
        if (msg.sender == address(this)) {
            revert("ERC20Wrapper: wrapped token cannot deposit to self");
        }
        if (_to == address(this)) {
            revert("ERC20Wrapper: wrapped token cannot mint to itself");
        }

        // Step 1: Caller transfers underlying token from self to ERC20Wrapper.

        // Basically msg.sender is the caller who calls depositFor() on the ERC20Wrapper
        //  contract.
        //      ie: msg.sender <<calls>> ERC20Wrapper.depositFor()

        // From within depositFor(), ERC20Wrapper (ie: "this") calls transferFrom() on the
        //  underlyingToken contract to transfer underlying tokens from msg.sender to
        //  itself.
        //      ie: ERC20Wrapper <<calls>> underlyingToken.transferFrom()
        // This means ERC20Wrapper is the spender that msg.sender needs to approve 1st with an
        //  appropriate allowance of underlying tokens.
        ERC20Core(underlying()).transferFrom(msg.sender, address(this), _value);
        if (emitEvent) {
            emit ERC20Wrapper_DepositedUnderlyingTokens(_value);
        }

        // Step 2: Caller mints matching amount of wrapped tokens to specified recipient.

        // Since mint() is in the same contract as depositFor(), its caller here remains the
        //  same - msg.sender. So basically the caller (ie: msg.sender) calls mint() on the
        //  ERC20Wrapper contract to mint ERC20Wrapper wrapped tokens to recipient.
        //      ie: msg.sender <<calls>> ERC20Wrapper.mint()
        mint(_to, _value);
    }

    /**
     * @notice  _withdraw()
     *          Contains the logic for the public function withdraw().
     * @param   _value      amount of underlying tokens caller wishes to withdraw
     * @param   emitEvent   flag to control whether to emit withdraw event
     */
    function _withdraw(uint256 _value, bool emitEvent) internal virtual {
        // Withdrawing to self creates a malicious circular loop logic that destroys contract
        //  viability, hence this check is performed here as part of the "core" logic for this
        //  contract.
        if (msg.sender == address(this)) {
            revert("ERC20Wrapper: wrapped token cannot withdraw to itself");
        }

        // Step 1: Caller burns wrapped token.

        // Basically msg.sender is the caller who calls withdraw() on the ERC20Wrapper contract.
        //      ie: msg.sender <<calls>> ERC20Wrapper.withdraw()

        // Since burn() is in the same contract as withdraw(), its caller here remains the
        //  same - msg.sender. So here the caller (ie: msg.sender) calls burn() on the
        //  ERC20Wrapper contract to burn wrapper tokens from his own balance.
        //      ie: msg.sender <<calls>> ERC20Wrapper.burn()
        burn(_value);

        // Step 2: Wrapped token contract transfers matching amount of underlyingToken to caller.

        // From within withdraw(), ERC20Wrapper calls transfer() on the underlyingToken contract
        //  to transfer matching amount of underlying tokens from its own balance to caller.
        //      ie: ERC20Wrapper <<calls>> underlyingToken.transfer()
        ERC20Core(underlying()).transfer(msg.sender, _value);
        if (emitEvent) {
            emit ERC20Wrapper_WithdrawnUnderlyingTokens(_value);
        }
    }

    /**
     * @notice  _withdrawTo()
     * @param   _to         recipient address to deposit underlying tokens to
     * @param   _value      amount of underlying tokens caller wishes to withdraw
     * @param   emitEvent   flag to control whether to emit withdraw event
     */
    function _withdrawTo(address _to, uint256 _value, bool emitEvent) internal virtual {
        // Withdrawing to self creates a malicious circular loop logic that destroys contract
        //  viability, hence this check is performed here as part of the "core" logic for this
        //  contract.
        if (_to == address(this)) {
            revert("ERC20Wrapper: wrapped token cannot withdraw to itself");
        }

        // Step 1: Caller burns wrapped token.

        // Basically msg.sender is the caller who calls withdrawTo() on the ERC20Wrapper contract.
        //      ie: msg.sender <<calls>> ERC20Wrapper.withdrawTo()

        // Since burn() is in the same contract as withdrawTo(), its caller here remains the
        //  same - msg.sender. So here the caller (ie: msg.sender) calls burn() on the
        //  ERC20Wrapper contract to burn wrapper tokens from his own balance.
        //      ie: msg.sender <<calls>> ERC20Wrapper.burn()
        burn(_value);

        // Step 2: Wrapped token contract transfers matching amount of underlyingToken to recipient.

        // From within withdrawTo(), ERC20Wrapper calls transfer() on the underlyingToken contract
        //  to transfer matching amount of underlying tokens from its own balance to recipient.
        //      ie: ERC20Wrapper <<calls>> underlyingToken.transfer()
        ERC20Core(underlying()).transfer(msg.sender, _value);
        if (emitEvent) {
            emit ERC20Wrapper_WithdrawnUnderlyingTokens(_value);
        }
    }
}