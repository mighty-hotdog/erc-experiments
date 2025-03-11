// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title   Pausable
 *          Adds a pause mechanism to any contract.
 * @author  @mighty_hotdog
 *          created 2025-03-10
 *          modified 2025-03-11 to change contract name and description
 *
 * @dev     The pause state is global, impacting the entire contract that inherits Pausable.
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
        if (_paused) {
            revert("Pausable: pause in effect");
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
        emit Pausable_Paused();
    }

    /**
     * @notice  unpause()
     *          Sets state to unpaused.
     * @dev     Emits the ERC20Pausable_Unpaused event.
     */
    function unpause() external {
        _paused = false;
        emit Pausable_Unpaused();
    }

    /**
     * @notice  isPaused()
     *          Returns true if pause is in effect. Otherwise returns false.
     */
    function isPaused() external view returns (bool) {
        return _paused;
    }
}