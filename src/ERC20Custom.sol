// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC165} from "forge-std/interfaces/IERC165.sol";
import {IERC4626} from "forge-std/interfaces/IERC4626.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract ERC20Custom {}