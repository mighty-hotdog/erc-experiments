// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";

/**
 * @title   ERC20Burnable
 *          Adds the burn() and burnFrom() functions to an ERC20 token https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog 2025-03-10
 */
abstract contract ERC20Burnable is ERC20Core {
    /**
     * @notice  burn()
     *          Burns tokens from caller's balance.
     * @param   _value      amount of tokens to burn
     *
     * @dev     caller == msg.sender
     *          note that msg.sender can never be address(0)
     *
     * @dev     reverts if _value > caller balance
     * @dev     _updateTokens() may revert on arithmetic underflow when calc token total supply and/or balances, will it really???
     */
    function burn(uint256 _value) public virtual returns (bool) {
        _updateTokens(msg.sender, address(0), _value);
        return true;
    }

    /**
     * @notice  burnFrom()
     *          Burns tokens from an owner balance.
     * @param   _from       owner address to burn from
     * @param   _value      amount of tokens to burn
     *
     * @dev     caller == msg.sender == spender
     *          note that msg.sender can never be address(0)
     *
     * @dev     reverts if _from == address(0)
     * @dev     reverts if _value > allowance
     * @dev     reverts if _value > owner balance
     * @dev     _updateTokens() may revert on arithmetic underflow when calc token total supply and/or balances, will it really???
     */
    function burnFrom(address _from, uint256 _value) public virtual returns (bool) {
        _spendAllowance(_from, msg.sender, _value);
        _updateTokens(_from, address(0), _value);
        return true;
    }
}
