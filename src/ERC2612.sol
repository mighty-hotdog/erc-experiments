// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20Core} from "./ERC20Core.sol";

/**
 * @title   ERC2612
 *          An implementation of the ERC2612 standard https://eips.ethereum.org/EIPS/eip-2612.
 * @author  @mighty_hotdog 2025-03-13
 */
abstract contract ERC2612 is ERC20Core {
    // events /////////////////////////////////////////////////////////////////////
    // emitted for successful permit() call
    event ERC2612_Permit(address indexed owner, address indexed spender, uint256 indexed value);

    // constants and immutables ///////////////////////////////////////////////////
    /**
     * @notice  PERMIT_TYPEHASH constant
     *          Hashed type-definition of the ERC2612 permit() message the owner signs.
     * @dev     This type-definition lays out how the message is structured, ie: the fields, the names, the types.
     * @dev     Allows recreating the message given the respective values.
     * @dev     Applies the EIP712 standard to the ERC2612 permit() message.
     */
    bytes32 private constant PERMIT_TYPEHASH = 
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    
    /**
     * @notice  _domainSeparator immutable variable
     *          Cached domain separator for this contract.
     * @dev     This binds a signature to be valid only for this contract and its deployment context.
     * @dev     Used when recreating the message digest signed by the owner.
     */
    bytes32 private immutable _domainSeparator;

    // state variables ////////////////////////////////////////////////////////////
    /**
     * @notice  _nonces mapping
     *          Keeps track of the current unused (and hence available) nonce for each owner address.
     * @dev     Nonce is increased by 1 for each successful permit() call.
     */
    mapping(address => uint256) private _nonces;    // nonces for each owner address

    // functions //////////////////////////////////////////////////////////////////
    /**
     * @notice  constructor()
     *          Creates and sets the domain separator for this contract.
     * @dev     The logic is shifted to the _createDomainSeparator() internal function to allow overriding.
     */
    constructor() {
        _domainSeparator = _createDomainSeparator();
    }

    /**
     * @notice  permit()
     *          Verifies the signature and then updates the allowance of the spender for the owner.
     * @param   owner       address of the owner
     * @param   spender     address of the spender
     * @param   value       allowance to be granted to the spender
     * @param   deadline    deadline for the signature
     * @param   v           v component of the signature
     * @param   r           r component of the signature
     * @param   s           s component of the signature
     *
     * @dev     caller == msg.sender, can be anyone
     * @dev     _owner and _spender can be contracts or EOAs
     * @dev     if deadline == uint256(-1), signature does not expire
     *
     * @dev     This implementation uses Solidity's built-in ecrecover() function to extract the signer address.
     *          Note that the Solidity docs state that ecrecover() is susceptible to signature malleability,
     *          ie: 2 different signatures can produce the same address.
     *          https://docs.soliditylang.org/en/v0.8.29/units-and-global-variables.html#mathematical-and-cryptographic-functions
     *          This is not a problem in most usecases, unless there is a requirement for the signature to be unique.
     *
     *          Alternative is to use the recover() function from OpenZeppelin's ECDSA library.
     *          This introduces a dependency (ie: OpenZeppelin) and costs slightly more gas, but solves the signature malleability issue.
     *          It also offers several overloaded versions of the same function that takes in different representations of the signature.
     */
    function permit(
        address owner, 
        address spender, 
        uint256 value, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s) public virtual {
        // check for invalid owner and spender
        if (owner == address(0)) {
            revert("ERC2612: invalid owner address(0)");
        }
        if (spender == address(0)) {
            revert("ERC2612: invalid spender address(0)");
        }

        // check if signature expired
        if (block.timestamp > deadline) {
            revert("ERC2612: signature expired");
        }

        // verify signature
        // 1. recreate message digest
        // note that _nonces[owner]++ increments the current avail nonce by 1, as specified by the ERC2612 standard
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))));
        // 2. extract signer address and compare with owner
        address signer = ecrecover(digest, v, r, s);
        if (signer != owner) {
            revert("ERC2612: invalid signer");
        }

        // emit event
        emit ERC2612_Permit(owner, spender, value);

        // update allowance as requested by the message
        _updateAllowance(owner, spender, value);
    }

    /**
     * @notice  nonces()
     *          Returns the current available nonce for the owner address.
     * @param   owner   address of the owner
     * @dev     A getter function that never reverts.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @notice  DOMAIN_SEPARATOR()
     *          Returns the domain separator for this contract.
     * @dev     A getter function that never reverts.
     */
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return _domainSeparator;
    }

    /**
     * @notice  _createDomainSeparator()
     *          Creates and returns the domain separator for this contract.
     * @dev     This logic is shifted here from the constructor to allow overriding.
     * @dev     Note the hack used to obtain the contract name and version.
     */
    function _createDomainSeparator() internal view virtual returns (bytes32) {
        // as a cheap hack, this implementation uses the abi.encodePacked() address of the contract,
        //  ie: address(this), as both the name and the version of the contract.
        //  override as desired.
        bytes memory cheapHack = abi.encodePacked(address(this));
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), 
                keccak256(cheapHack), 
                keccak256(cheapHack), 
                block.chainid, 
                address(this)));
    }
}