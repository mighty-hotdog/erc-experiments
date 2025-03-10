// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// these imports are just for reference, not used in the contract
//import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC165} from "forge-std/interfaces/IERC165.sol";
import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

// these imports are used in the contract
import {ERC20Core} from "./ERC20Core.sol";
import {ERC20Mintable} from "./ERC20Mintable.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {ERC20Metadata} from "./ERC20Metadata.sol";

/**
 * @title   ERC20SampleCustomToken
 *          A sample contract for a custom ERC20 token.
 * @author  @mighty_hotdog 2025-03-10
 */
contract ERC20SampleCustomToken is ERC20Core, ERC20Mintable, ERC20Burnable, ERC20Metadata {
    // events
    event SCT_Minted(address indexed toAccount, uint256 amount);
    event SCT_Burned(address indexed fromAccount, uint256 amount);

    // constants
    uint256 public constant STARTING_TOTAL_SUPPLY = 1e9; // 1 billion tokens
    uint8 public constant DECIMALS = 8;

    // functions
    constructor() ERC20Metadata("SampleCustomToken", "SCT") {
        mint(msg.sender, STARTING_TOTAL_SUPPLY);
    }

    function mint(address _to, uint256 _value) public override returns (bool) {
        super.mint(_to, _value);
        emit SCT_Minted(_to, _value);
        return true;
    }

    function burn(uint256 _value) public override returns (bool) {
        super.burn(_value);
        emit SCT_Burned(msg.sender, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public returns (bool) {
        burnFrom(_from, _value);
        emit SCT_Burned(_from, _value);
        return true;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}
