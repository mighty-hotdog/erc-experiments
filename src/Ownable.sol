// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract Ownable {
    error Ownable_InvalidOwner(address owner);
    error Ownable_UnauthorizedAccount(address account);

    event Ownable_OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;

    /**
     * @notice  onlyOwner() modifier
     *          Allow functions to proceed only if caller == owner.
     * @dev     reverts if caller != owner
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @notice  constructor()
     *          Initializes contract with an initial owner.
     * @dev     reverts if initialOwner == address(0)
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert Ownable_InvalidOwner(initialOwner);
        }
        _transferOwnership(initialOwner);
        _owner = initialOwner;
    }

    /**
     * @notice  transferOwnership()
     *          Allows current owner to transfer ownership to a new address.
     * @dev     reverts if caller != current owner
     * @dev     reverts if newOwner == address(0)
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert Ownable_InvalidOwner(newOwner);
        }
        _transferOwnership(newOwner);
    }

    /**
     * @notice  owner()
     *          Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @notice  _checkOwner()
     *          Checks if caller == owner.
     * @dev     Reverts if caller != owner.
     * @dev     Designed to work with the onlyOwner() modifier.
     *          Since modifier cannot be virtual, this is a workaround, which is to shift the caller
     *          checking logic to this internal function that can then be overridden if desired.
     */
    function _checkOwner() internal view virtual {
        if (msg.sender != owner()) {
            revert Ownable_UnauthorizedAccount(msg.sender);
        }
    }

    /**
     * @notice  _transferOwnership()
     *          Transfers ownership of the contract to a new account (`newOwner`).
     * @dev     Designed to work with the constructor().
     *          Shifting the constructor logic for setting the initial owner into this function
     *          allows it to be overridden with different logic if desired.
     * @dev     Also works with transferOwnership() function.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit Ownable_OwnershipTransferred(oldOwner, newOwner);
    }
}