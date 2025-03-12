// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";
import {ERC20Metadata} from "./ERC20Metadata.sol";
import {ERC20Mintable} from "./ERC20Mintable.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {ERC20Wrapper} from "./ERC20Wrapper.sol";
import {Pausable} from "./Pausable.sol";
import {Ownable} from "./Ownable.sol";

/**
 * @title   ERC20SampleCustomToken
 *          A sample contract for a custom ERC20 token.
 * @author  @mighty_hotdog
 *          created 2025-03-10
 *          modified 2025-03-11
 *              to add capping functionality with new ERC20Mintable
 *              to add pausing functionality with ERC20Pausable
 *              to add ownership functionality with ERC20Ownable
 */
contract ERC20SampleCustomToken is ERC20Core, ERC20Metadata, ERC20Wrapper, Ownable {
    // constants
    uint256 public constant MAX_TOKEN_SUPPLY = type(uint256).max;
    uint8 public constant DECIMALS = 8;

    // functions
    constructor(address initialOwner, address underlyingToken)
        ERC20Metadata("SampleWrappedToken", "SWT")
        ERC20Wrapper(underlyingToken, MAX_TOKEN_SUPPLY)
        Ownable(initialOwner) {}

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}
