// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IERC20CustomErrorsUpgradeable {
    error ERC20TransferFailed(address to, uint256 balance);
}
