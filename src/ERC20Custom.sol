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

contract ERC20Custom {
    // ****************************************************************************
    // ERC20 required implementations
    // ****************************************************************************

    // events
    /**
     * @notice  Transfer()
     *          emitted when tokens are transferred, including zero value transfers
     * @dev     triggered also when tokens are created aka minting, ie: _from == 0x0
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * @notice  Approval()
     *          emitted on successful call to approve() function
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    address[] internal _owners;

    // functions
    /**
     * @notice  totalSupply()
     *          returns the total token supply
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice  balanceOf()
     *          returns the balance of an account
     * @param   _owner  address of the account
     * @dev     caller == msg.sender, can be anyone
     * @dev     _owner can be a contract or an EOA, standard doesn't specify
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    /**
     * @notice  transfer()
     *          transfers tokens from caller to an address and fires Transfer event
     * @param   _to     address to transfer to
     * @param   _value  amount of tokens to transfer
     * @dev     caller == msg.sender
     * @dev     reverts if caller balance < _value
     * @dev     _value == 0 allowed and valid
     *
     * @dev     _to can be a contract or an EOA, standard doesn't specify
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {}

    /**
     * @notice  transferFrom()
     *          transfers tokens from source address to destination address and fires Transfer event
     * @param   _from   source address to transfer from
     * @param   _to     destination address to transfer to
     * @param   _value  amount of tokens to transfer
     * @dev     concept of "allowance", "spender" and "owner":
     *          "allowance" is amount of tokens a "spender" is given approval, by an "owner", to spend from owner's balance
     *          implementation of ERC20 standard must also implement this mechanism
     * @dev     caller == msg.sender == "spender"
     * @dev     _from == "owner"
     * @dev     reverts if allowance == 0
     * @dev     reverts if allowance < _value
     * @dev     reverts if source address balance < _value
     * @dev     _value == 0 allowed and valid
     *
     * @dev     _from and _to can be contracts or EOAs, standard doesn't specify
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

    /**
     * @notice  approve()
     *          grants approval to spender to spend tokens from caller balance and fires Approval event
     * @param   _spender    spender address
     * @param   _value      allowance, ie: amount of tokens spender is allowed to spend from caller/owner's balance
     * @dev     spender may spend the allowance in single or multiple transactions
     * @dev     calling this function sets the allowance if non exists, or overrides any existing with the new value
     *
     * @dev     caller == msg.sender == "owner" in this case
     * @dev     caller and _spender can be a contract or an EOA, standard doesn't specify
     * @dev     reverts if _value is 0
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {}

    /**
     * @notice  allowance()
     *          returns remaining allowance spender is still allowed to spend from owner's balance
     * @param   _owner      owner address
     * @param   _spender    spender address
     *
     * @dev     caller == msg.sender, can be anyone
     * @dev     _owner and _spender can be contracts or EOAs, standard doesn't specify
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }

    // ****************************************************************************
    // ERC20 optional extensions
    // ****************************************************************************

    // functions
    /**
     * @notice  name()
     *          returns the name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice  symbol()
     *          returns the symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice  decimals()
     *          returns the number of decimals aka precision of the token
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    // ****************************************************************************
    // ERC20 custom extensions specific to this implementation
    //
    //  these are not part of the ERC20 standard but have been carefully
    //  implemented to ensure that this implementation is fully backward
    //  compatible with the ERC20 standard
    //
    //  maybe should move these to separate inheritable contracts
    // ****************************************************************************

    // 1. add proper mint and burn mechanism that also trigger associated events
    // 2. add ownership mechanism that can be used to protect certain functions
    // 3. add "pluggable" extensions for ERC20 improvements ERC223, ERC677, ERC1363
    // 4. add "pluggable" extensions for ERC20 addon ERC165
    // 5. add pausable mechanism
    // 6. add capping mechanism

    // events

    // modifiers

    // functions
}