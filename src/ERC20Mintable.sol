// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";

/**
 * @title   ERC20Mintable
 *          Adds a mint() function and a capping mechanism to an ERC20 token https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog
 *          created 2025-03-10 with mint() function
 *          modified 2025-03-11 to add capping mechanism
 *          modified 2025-03-12 to update some variable and function names in the capping mechanism to be more informative
 */
abstract contract ERC20Mintable is ERC20Core {
    uint256 private immutable _maxTokenSupply;

    /**
     * @notice  constructor()
     *          Sets max # of the ERC20 token.
     * @param   maxTokenSupply_    max # of tokens that can exist
     *
     * @dev     caller == msg.sender, can be anyone, token protocols may like additional restrictions/logic here
     *
     * @dev     Reverts if maxTokenSupply_ == 0.
     */
    constructor(uint256 maxTokenSupply_) {
        if (maxTokenSupply_ == 0) {
            revert("ERC20Mintable: max token supply cannot be 0");
        } else {
            _maxTokenSupply = maxTokenSupply_;
        }
    }

    /**
     * @notice  maxTokenSupply()
     *          Returns the max # of the ERC20 token that can exist.
     * @dev     Basically a getter function, hence never reverts.
     */
    function maxTokenSupply() public view virtual returns (uint256) {
        return _maxTokenSupply;
    }
    
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
        if (totalSupply() + _value > maxTokenSupply()) {
            revert("ERC20Mintable: max token supply exceeded");
        }
        _updateTokens(address(0), _to, _value);
        return true;
    }
}
