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

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ERC20Core
 *        An implementation of the ERC20 standard https://eips.ethereum.org/EIPS/eip-20.
 * @dev   This contract is NOT INTENDED to be used directly. In fact this implementation is unusable as there
 *        is no mechanism for minting new tokens. Also there is no reentrancy guard for functions like
 *        transfer(), transferFrom(), and approve() that require it.
 *        This is intended to be used as a base class for other more complete ERC20 implementations
 * @dev   ReentrancyGuard from OpenZeppelin is used to guard against reentrancy
 */
abstract contract ERC20Core is ReentrancyGuard {
    // ****************************************************************************
    // ERC20 required implementations
    // ****************************************************************************

    // events
    /**
     * @notice  Transfer()
     *          Emitted when tokens are transferred, including zero value transfers.
     * @dev     Also triggered in token creation aka minting, ie: _from == 0x0.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * @notice  Approval()
     *          Emitted on successful call to approve() function.
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // state variables
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // metadata
    string private _name;
    string private _symbol;

    // functions
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @notice  totalSupply()
     *          Returns the total token supply.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice  balanceOf()
     *          Returns the balance of an account.
     * @param   _owner  address of the account
     * @dev     caller == msg.sender, can be anyone
     * @dev     _owner can be a contract or an EOA, standard doesn't specify
     */
    function balanceOf(address _owner) public view virtual returns (uint256 balance) {
        return _balances[_owner];
    }

    /**
     * @notice  transfer()
     *          Transfers tokens from caller to an address and fires Transfer event.
     * @param   _to     address to transfer to
     * @param   _value  amount of tokens to transfer
     * @dev     caller == msg.sender
     * @dev     reverts if caller balance < _value
     * @dev     _value == 0 allowed and valid
     *
     * @dev     _to can be a contract or an EOA, standard doesn't specify
     * @dev     vulnerabilities:
     *          1. reentrancy
     *          2. _balances[_to] overflow
     */
    function transfer(address _to, uint256 _value) public virtual nonReentrant returns (bool success) {
        if (_value > _balances[msg.sender]) {
            revert("ERC20: transfer amount exceeds balance");
        }
        emit Transfer(msg.sender, _to, _value);
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;   // just let it revert upon overflow
        return success;
    }

    /**
     * @notice  transferFrom()
     *          Transfers tokens from source address to destination address and fires Transfer event.
     * @param   _from   source address to transfer from
     * @param   _to     destination address to transfer to
     * @param   _value  amount of tokens to transfer
     * @dev     Concepts of "allowance", "spender" and "owner":
     *          An "allowance" is amount of tokens a "spender" is given approval, by an "owner", to spend from owner's balance
     *          implementation of ERC20 standard must also implement this mechanism.
     * @dev     caller == msg.sender == "spender"
     * @dev     _from == "owner"
     * @dev     reverts if allowance == 0
     *          This could mean spender allowance has been depleted to zero, or that the owner has never approved any allowance.
     * @dev     reverts if allowance < _value
     * @dev     reverts if source address balance < _value
     * @dev     _value == 0 allowed and valid
     *
     * @dev     _from and _to can be contracts or EOAs, standard doesn't specify
     * @dev     vulnerabilities:
     *          1. reentrancy
     *          2. _balances[_to] overflow
     */
    function transferFrom(address _from, address _to, uint256 _value) public nonReentrant returns (bool success) {
        if (_value > _balances[_from]) {
            revert("ERC20: transfer amount exceeds balance");
        }
        if (_allowances[_from][msg.sender] == 0) {
            revert("ERC20: insufficient allowance");
        }
        if (_allowances[_from][msg.sender] < _value) {
            revert("ERC20: insufficient allowance");
        }
        emit Transfer(_from, _to, _value);
        _allowances[_from][msg.sender] -= _value;
        _balances[_from] -= _value;
        _balances[_to] += _value;   // just let it revert upon overflow
        return success;
    }

    /**
     * @notice  approve()
     *          Grants approval to spender to spend tokens from caller balance and fires Approval event.
     * @param   _spender    spender address
     * @param   _value      allowance, ie: amount of tokens spender is allowed to spend from caller/owner's balance
     * @dev     Spender may spend the allowance in single or multiple transactions.
     * @dev     Calling this function sets the allowance if non exists, or overrides any existing with the new value.
     *
     * @dev     caller == msg.sender == "owner" in this case
     * @dev     caller and _spender can be a contract or an EOA, standard doesn't specify
     * @dev     reverts if _value is 0
     * @dev     vulnerabilities:
     *          1. reentrancy, ie: calling approve() when transfer() or transferFrom() are being processed
     */
    function approve(address _spender, uint256 _value) public nonReentrant returns (bool success) {
        if (_value == 0) {
            revert("ERC20: approve 0");
        }
        emit Approval(msg.sender, _spender, _value);
        _allowances[msg.sender][_spender] = _value;
        return success;
    }

    /**
     * @notice  allowance()
     *          Returns remaining allowance spender is still allowed to spend from owner's balance.
     * @param   _owner      owner address
     * @param   _spender    spender address
     *
     * @dev     caller == msg.sender, can be anyone
     * @dev     _owner and _spender can be contracts or EOAs, standard doesn't specify
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }

    // internal functions
    function _updateTokens(address _from, address _to, uint256 _value) internal virtual {
        if ((_from == address(0)) && (_to != address(0))) {
            // minting
            _totalSupply += _value;
            _balances[_to] += _value;
        } else if ((_from != address(0)) && (_to == address(0))) {
            // burning
            if (_balances[_from] < _value) {
                revert("ERC20: burn amount exceeds balance");
            }
            _totalSupply -= _value;
            _balances[_from] -= _value;
        } else if ((_from != address(0)) && (_to != address(0))) {
            // transfer
            if (_balances[_from] < _value) {
                revert("ERC20: transfer amount exceeds balance");
            }
            _balances[_from] -= _value;
            _balances[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
    }
    function _updateAllowances(address _owner, address _spender, uint256 _value) internal virtual {
        if (_owner != address(0)) {
            revert("ERC20: invalid approver address(0)");
        }
        if (_spender != address(0)) {
            revert("ERC20: invalid spender address(0)");
        }
        if (_value == 0) {
            revert("ERC20: approve 0");
        }
        _allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }
    function _spendAllowance(address _owner, address _spender, uint256 _value) internal virtual {
        if (_owner == address(0)) {
            revert("ERC20: invalid owner address(0)");
        }
        if (_spender == address(0)) {
            revert("ERC20: invalid spender address(0)");
        }
        if (_allowances[_owner][_spender] == 0) {
            revert("ERC20: insufficient allowance");
        }
        if (_allowances[_owner][_spender] < _value) {
            revert("ERC20: insufficient allowance");
        }
        _allowances[_owner][_spender] -= _value;
    }
}