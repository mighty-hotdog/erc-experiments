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
 * @title   ERC20Core
 *          An implementation of the ERC20 standard https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog 2025-03-10
 * @dev     This contract is NOT INTENDED to be used directly. In fact this implementation is unusable
 *          as there is no mechanism for minting new tokens.
 *          This is intended to be used as a base class for other more complete ERC20 implementations.
 * @dev     ReentrancyGuard from OpenZeppelin is used to guard against reentrancy.
 */
abstract contract ERC20Core is ReentrancyGuard {
    // ****************************************************************************
    // ERC20 required implementations
    // ****************************************************************************

    // events /////////////////////////////////////////////////////////////////////
    /**
     * @notice  Transfer()
     *          Emitted when tokens are transferred, including zero value transfers.
     * @dev     Also triggered in token creation aka minting, ie: _from == address(0).
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * @notice  Approval()
     *          Emitted on successful call to approve() function.
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // state variables ////////////////////////////////////////////////////////////
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // functions //////////////////////////////////////////////////////////////////

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
     *          Transfers tokens from caller to a recipient address and fires Transfer event.
     * @param   _to     recipient address to transfer to
     * @param   _value  amount of tokens to transfer
     *
     * @dev     caller == msg.sender
     * @dev     _to can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if _to == address(0)
     * @dev     reverts if caller balance < _value
     * @dev     _value == 0 allowed and valid
     * @dev     Reentrancy vulnerability.
     *          Mitigated by inheriting ReentrancyGuard at contract level and using nonReentrant modifier here
     *          at function level.
     *
     * @dev     Can be overridden to implement additional logic, eg: more restrictions.
     *          Any override should also call _updateTokens() or its overridden version to effect the needed
     *          state changes.
     */
    function transfer(address _to, uint256 _value) public virtual nonReentrant returns (bool) {
        if (_to == address(0)) {
            revert("ERC20Core: invalid recipient address(0)");
        }
        _updateTokens(msg.sender, _to, _value);
        return true;
    }

    /**
     * @notice  transferFrom()
     *          Transfers tokens from source address to recipient address and fires Transfer event.
     * @param   _from   source address to transfer from
     * @param   _to     recipient address to transfer to
     * @param   _value  amount of tokens to transfer
     * @dev     Concepts of "allowance", "spender" and "owner":
     *          An "allowance" is amount of tokens a "spender" is given approval, by an "owner", to spend from
     *          owner's balance.
     *          Implementations of ERC20 standard must implement this mechanism.
     *
     * @dev     caller == msg.sender == "spender"
     * @dev     _from == "owner"
     * @dev     _from and _to can be contracts or EOAs, standard doesn't specify
     *
     * @dev     reverts if _from == address(0)
     * @dev     reverts if _to == address(0)
     * @dev     reverts if _value > allowance
     * @dev     reverts if _value > source balance
     * @dev     _value == 0 allowed and valid
     * @dev     Reentrancy vulnerability.
     *          Mitigated by inheriting ReentrancyGuard at contract level and using nonReentrant modifier here
     *          at function level.
     *
     * @dev     Can be overridden to implement additional logic, eg: more restrictions.
     *          Any override should also call _spendAllowance() and _updateTokens() or their overridden versions
     *          to effect the needed state changes.
     */
    function transferFrom(address _from, address _to, uint256 _value) public virtual nonReentrant returns (bool) {
        if (_from == address(0)) {
            revert("ERC20Core: invalid source address(0)");
        }
        if (_to == address(0)) {
            revert("ERC20Core: invalid recipient address(0)");
        }
        _spendAllowance(_from, msg.sender, _value);
        _updateTokens(_from, _to, _value);
        return true;
    }

    /**
     * @notice  approve()
     *          Grants approval to spender to spend tokens from caller balance and fires Approval event.
     * @param   _spender    spender address
     * @param   _value      allowance, ie: amount of tokens spender is allowed to spend from caller's balance
     * @dev     Spender may spend the allowance in single or multiple transactions.
     * @dev     Calling this function sets the allowance if none exists, or overrides existing with new value.
     *
     * @dev     caller == msg.sender == "owner" in this case
     * @dev     caller and _spender can be a contract or an EOA, standard doesn't specify
     *
     * @dev     reverts if _spender == address(0)
     * @dev     Reentrancy vulnerability.
     *          Mitigated by inheriting ReentrancyGuard at contract level and using nonReentrant modifier here at
     *          function level.
     *
     * @dev     Can be overridden to implement additional logic, eg: more restrictions.
     *          Any override should also call _updateAllowance() or its overridden version to effect the needed
     *          state changes.
     */
    function approve(address _spender, uint256 _value) public virtual nonReentrant returns (bool) {
        _updateAllowance(msg.sender, _spender, _value);
        return true;
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
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }

    // internal functions /////////////////////////////////////////////////////////
    /**
     * @notice  _updateTokens()
     *          Effects token transfers, mints and burns by updating balances and totalSupply accordingly.
     * @param   _from   source address to transfer tokens from
     * @param   _to     destination address to transfer tokens to
     * @param   _value  amount of tokens to transfer
     * @dev     This function is intended to be the only place where token balances and total supply are modified.
     *          As such, its design is solely concerned with correctly updating balances and total supply, including
     *          all error checks and reverts needed in performing these operations correctly.
     *          eg: balance < _value, overflow/underflow
     * @dev     Application logic, such as address restrictions, allowances, reentrancy, etc. to be handled by higher
     *          level functions that implement those logic, and then call this function to effect the updates.
     *
     * @dev     caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here
     * @dev     reverts if _value > _balances[_from]
     * @dev     reverts on arithmetic overflow/underflow when calc totalSupply and _balances
     * @dev     Emits Transfer event as specified in ERC20 standard.
     *
     * @dev     Can be overridden to implement additional logic.
     *          Any override should still emit Transfer event as specified in ERC20 standard.
     */
    function _updateTokens(address _from, address _to, uint256 _value) internal virtual {
        if ((_from == address(0)) && (_to != address(0))) {
            // minting
            _totalSupply += _value;
            _balances[_to] += _value;
        } else if ((_from != address(0)) && (_to == address(0))) {
            // burning
            if (_value > _balances[_from]) {
                revert("ERC20Core: burn amount exceeds balance");
            }
            _totalSupply -= _value;
            _balances[_from] -= _value;
        } else if ((_from != address(0)) && (_to != address(0))) {
            // transfer
            if (_value > _balances[_from]) {
                revert("ERC20Core: transfer amount exceeds balance");
            }
            _balances[_from] -= _value;
            _balances[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
    }

    /**
     * @notice  _updateAllowance()
     *          Updates allowance with new value when approve(), and/or similiar functions, are called.
     * @param   _owner      owner address
     * @param   _spender    spender address
     * @param   _value      allowance
     * @dev     This function is intended to be the only place where allowances are modified due to approvals.
     *
     * @dev     caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here
     *
     * @dev     reverts if _owner == address(0), to keep that mapping entry "clean"
     * @dev     reverts if _spender == address(0), to keep that mapping entry "clean"
     * @dev     Emits Approval event as specified in ERC20 standard.
     *
     * @dev     Can be overridden to implement additional logic.
     *          Any override should still emit Approval event as specified in ERC20 standard.
     */
    function _updateAllowance(address _owner, address _spender, uint256 _value) internal virtual {
        if (_owner != address(0)) {
            revert("ERC20Core: invalid approver address(0)");
        }
        if (_spender != address(0)) {
            revert("ERC20Core: invalid spender address(0)");
        }
        _allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    /**
     * @notice  _spendAllowance()
     *          Updates allowances when spending occurs.
     * @param   _owner      owner address
     * @param   _spender    spender address
     * @param   _value      amount of allowance to spend
     * @dev     This function is intended to be the only place where allowances are modified due to spending.
     *
     * @dev     caller == msg.sender, can be anyone, implementations might like additional restrictions/logic here
     *
     * @dev     reverts if _owner == address(0), to keep that mapping entry "clean"
     * @dev     reverts if _spender == address(0), to keep that mapping entry "clean"
     * @dev     reverts if _value > allowance
     *
     * @dev     Can be overridden to implement additional logic.
     */
    function _spendAllowance(address _owner, address _spender, uint256 _value) internal virtual {
        if (_owner == address(0)) {
            revert("ERC20Core: invalid owner address(0)");
        }
        if (_spender == address(0)) {
            revert("ERC20Core: invalid spender address(0)");
        }
        if (_value > _allowances[_owner][_spender]) {
            revert("ERC20Core: insufficient allowance");
        }
        _allowances[_owner][_spender] -= _value;
    }
}