// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrors.sol";

/// @title A smart contract that checks for burned tokens and mints new tokens based on the burned tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfBurn is Context, ERC20 {
    uint256 private _lastBurned;
    address[] internal _burnAddresses;
    address[] internal _burnContracts;

    constructor(
        address[] memory burnAddresses,
        address[] memory burnContracts
    ) {
        _burnAddresses = burnAddresses;
        _burnContracts = burnContracts;
    }

    /// @notice Get the last amount of tokens that were burned.
    /// @dev Returns the last amount of tokens that were burned.
    /// @return (uint256) - the last amount of tokens that were burned.
    function lastBurned() public view returns (uint256) {
        return _lastBurned;
    }

    /// @dev Set the last amount of tokens that were burned. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were burned.
    function setLastBurned(uint256 value) internal virtual {
        _lastBurned = value;
    }

    /// @notice Get the amount of tokens eligible to be minted.
    /// @dev Returns the amount of tokens eligible to be minted.
    /// @return balance (uint256) - the amount of tokens eligible to be minted.
    function getCurrentBurned()
        public
        payable
        virtual
        returns (uint256 balance)
    {
        address[] memory eligibleBurnAddresses = _burnAddresses;
        address[] memory eligibleBurnContracts = _burnContracts;
        uint256 addressLength = _burnAddresses.length;
        uint256 contractLength = _burnContracts.length;
        for (uint256 i; i < contractLength; ++i) {
            ERC20 tokenContract = ERC20(eligibleBurnContracts[i]);
            for (uint256 j; j < addressLength; ++j) {
                balance += tokenContract.balanceOf(eligibleBurnAddresses[j]);
            }
        }
        return balance;
    }

    /// @notice Get the ratio of tokens to mint.
    /// @dev Returns the ratio of tokens to mint. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function mintRatio() public pure virtual returns (uint256) {
        return 5000;
    }

    /// @notice Get the ratio of tokens to mint for ProofOfBurn.
    /// @dev Returns the ratio of tokens to mint for ProofOfBurn. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function burnMintRatio() public view virtual returns (uint256) {
        return mintRatio();
    }

    /// @dev Handle access control, accounting, and any conditions here before minting, revert if failed.
    /// @param sender (address) - the address of the sender.
    /// @param account (address) - the address of the account.
    function beforeMintBurned(
        address sender,
        address account
    ) internal virtual {}

    /// @dev Update the mint registry or perform other accounting. Override to customize.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens minted.
    function afterMintBurned(address account, uint256 value) internal virtual {}

    /// @dev Mints the burned tokens for the configured contracts and addresses.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function _doMintBurned(address account)
        internal
        virtual
        returns (uint256)
    {
        uint256 balance = getCurrentBurned();
        uint256 tokensLastBurned = lastBurned();
        if (balance <= tokensLastBurned) {
            revert NoTokensToMint();
        }
        uint256 tokens = (balance - tokensLastBurned) * burnMintRatio() / 10000;
        setLastBurned(balance);
        _mint(account, tokens);
        return tokens;
    }

    /// @notice Mints the burned tokens for the configured contracts and addresses.
    /// @dev Mints the burned tokens for the configured contracts and addresses.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintBurned() public payable virtual returns (uint256 tokens) {
        address sender = _msgSender();
        beforeMintBurned(sender, sender);
        tokens = _doMintBurned(sender);
        afterMintBurned(sender, tokens);
        return tokens;
    }

    /// @notice Mints the burned tokens for the configured contracts and addresses.
    /// @dev Mints the burned tokens for the configured contracts and addresses.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintBurnedFor(address account)
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintBurned(sender, account);
        tokens = _doMintBurned(account);
        afterMintBurned(account, tokens);
        return tokens;
    }
}
