// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   Pausable
 *          Adds a pause mechanism to any contract.
 * @author  @mighty_hotdog
 *          created 2025-03-10
 *          modified 2025-03-11
 *              to change contract name and description
 *              shifted modifier and constructor logic to internal functions to allow overriding
 *
 * @dev     The pause state is global, visible to the entire contract that inherits Pausable.
 * @dev     The pausable modifier allows the selective application of the pause mechanism to
 *          only certain functions.
 */
abstract contract Pausable {
    event Pausable_Paused();
    event Pausable_Unpaused();

    bool private _paused;

    /**
     * @notice  pausable() modifier
     *          Allows called functions to proceed only when not in paused state.
     *          This is the core of the pause mechanism provided by this contract.
     * @dev     reverts if pause is in effect
     */
    modifier pausable() {
        _checkIfPaused();
        _;
    }

    /**
     * @notice  constructor
     *          Initializes paused state to false.
     */
    constructor() {
        _unpause(false);
    }

    /**
     * @notice  pause()
     *          Sets state to paused.
     * @dev     Emits the ERC20Pausable_Paused event.
     */
    function pause() external virtual {
        _pause(true);
    }

    /**
     * @notice  unpause()
     *          Sets state to unpaused.
     * @dev     Emits the ERC20Pausable_Unpaused event.
     */
    function unpause() external virtual {
        _unpause(true);
    }

    /**
     * @notice  isPaused()
     *          Returns true if pause is in effect. Otherwise returns false.
     * @dev     Basically a getter function. Never reverts.
     */
    function isPaused() external view virtual returns (bool) {
        return _paused;
    }

    /**
     * @notice  _checkIfPaused()
     *          Reverts if pause is in effect.
     * @dev     Designed to work with the pausable() modifier.
     *          Since a modifier cannot be virtual, by shifting the pause checking logic here
     *          to this function, it can be overridden if desired.
     */
    function _checkIfPaused() internal view virtual {
        if (_paused) {
            revert("Pausable: pause in effect");
        }
    }

    /**
     * @notice  _pause() and _unpause()
     *          Sets state to paused or unpaused for the whole contract.
     * @dev     Shifting the state setting logic to these internal functions allows more flexibility
     *          (eg: with the event emission). And they can be overridden if desired.
     */
    function _pause(bool emitEvent) internal virtual {
        _paused = true;
        if (emitEvent) {
            emit Pausable_Paused();
        }
    }
    function _unpause(bool emitEvent) internal virtual {
        _paused = false;
        if (emitEvent) {
            emit Pausable_Unpaused();
        }
    }
}