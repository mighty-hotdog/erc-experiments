// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   ERC20Pausable
 *          Adds a pause mechanism to an ERC20 token https://eips.ethereum.org/EIPS/eip-20.
 * @author  @mighty_hotdog 2025-03-10
 */
abstract contract ERC20Pausable {
    event ERC20Pausable_Paused();
    event ERC20Pausable_Unpaused();

    bool private _paused;

    /**
     * @notice  pausable() modifier
     *          Allows called functions to proceed only when not in paused state.
     *          This is the core of the pause mechanism provided by this contract.
     * @dev     reverts if pause is in effect
     */
    modifier pausable() {
        if (_paused) {
            revert("ERC20Pausable: token is paused");
        }
        _;
    }

    /**
     * @notice  constructor
     *          Initializes paused state to false.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @notice  pause()
     *          Sets state to paused.
     * @dev     Emits the ERC20Pausable_Paused event.
     */
    function pause() external {
        _paused = true;
        emit ERC20Pausable_Paused();
    }

    /**
     * @notice  unpause()
     *          Sets state to unpaused.
     * @dev     Emits the ERC20Pausable_Unpaused event.
     */
    function unpause() external {
        _paused = false;
        emit ERC20Pausable_Unpaused();
    }

    /**
     * @notice  isPaused()
     *          Returns true if pause is in effect. Otherwise returns false.
     */
    function isPaused() external view returns (bool) {
        return _paused;
    }
}