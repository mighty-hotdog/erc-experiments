// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";

/**
 * @title   ERC20Mintable
 *          Adds a mint() function to an ERC20 token https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog 2025-03-10
 */
abstract contract ERC20Mintable is ERC20Core {

    /**
     * @notice  mint()
     *          Mints new tokens to a recipient address.
     * @param   _to         recipient address
     * @param   _value      amount of tokens to mint
     *
     * @dev     caller == msg.sender, can be anyone, implementations may like additional restrictions/logic here
     * @dev     _to can be a contract or an EOA
     *
     * @dev     reverts if _to == address(0)
     * @dev     _updateTokens() may revert on arithmetic overflow when calc token total supply and balances
     */
    function mint(address _to, uint256 _value) public virtual returns (bool) {
        if (_to == address(0)) {
            revert("ERC20Mintable: invalid recipient address(0)");
        }
        _updateTokens(address(0), _to, _value);
        return true;
    }
}