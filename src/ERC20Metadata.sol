// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";

/**
 * @title   ERC20Metadata
 *          Implements the optional metadata part of the ERC20 standard https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog 2025-03-10
 */
abstract contract ERC20Metadata is ERC20Core {
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @notice  name()
     *          Returns the name of the token, as set in the constructor.
     * @dev     Essentially a getter function, hence never reverts.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @notice  symbol()
     *          Returns the symbol of the token, as set in the constructor.
     * @dev     Essentially a getter function, hence never reverts.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @notice  decimals()
     *          Returns the decimals of the token, as set in the constructor.
     * @dev     Returns the number of decimals used to get its user representation.
     *          For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed
     *          to a user as `5.05` (`505 / 10 ** 2`).
     *          Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei.
     *
     * @dev     Defaults to 18, but can be overridden to return a different value.
     * @dev     Essentially a getter function, hence never reverts.
     * @dev     Note this is purely a cosmetic value for display purposes and has zero impact on any calc.
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }
}