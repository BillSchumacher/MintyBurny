// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC20BurnRegistry} from "./ERC20BurnRegistry.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrors.sol";

/// @title A smart contract that checks for burned tokens and mints new tokens based on the burned tokens.
/// @custom:requires burnerContracts to implement ERC20BurnRegistry
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfBurner is Context, ERC20 {
    mapping(address => uint256) private _lastBurnerBurned;
    address[] internal _burnerContracts;

    constructor(address[] memory burnerContracts) {
        _burnerContracts = burnerContracts;
    }

    /// @notice Get the last amount of tokens that were burned.
    /// @dev Returns the last amount of tokens that were burned.
    /// @return (uint256) - the last amount of tokens that were burned.
    function lastBurnerBurned() public view returns (uint256) {
        return _lastBurnerBurned[_msgSender()];
    }

    /// @dev Set the last amount of tokens that were burned. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were burned.
    function setLastBurnerBurned(uint256 value) internal virtual {
        _lastBurnerBurned[_msgSender()] = value;
    }

    /// @notice Get the amount of tokens eligible to be minted.
    /// @dev Returns the amount of tokens eligible to be minted.
    /// @return balance (uint256) - the amount of tokens eligible to be minted.
    function getCurrentBurnerBurned()
        public
        payable
        virtual
        returns (uint256 balance)
    {
        address[] memory eligibleBurnerContracts = _burnerContracts;
        uint256 contractLength = eligibleBurnerContracts.length;
        address sender = _msgSender();
        for (uint256 i; i < contractLength;) {
            ERC20BurnRegistry tokenContract =
                ERC20BurnRegistry(eligibleBurnerContracts[i]);
            balance += tokenContract.burnedFrom(sender);
            unchecked {
                ++i;
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

    /// @notice Get the ratio of tokens to mint for ProofOfBurner.
    /// @dev Returns the ratio of tokens to mint for ProofOfBurner. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function mintBurnerRatio() public view virtual returns (uint256) {
        return mintRatio();
    }

    /// @dev Handle access control, accounting, and any conditions here before minting, revert if failed.
    /// @param sender (address) - the address of the sender.
    /// @param account (address) - the address of the account.
    function beforeMintBurnerBurned(
        address sender,
        address account
    ) internal virtual {}

    /// @dev Update the mint registry or perform other accounting. Override to customize.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens minted.
    function afterMintBurnerBurned(
        address account,
        uint256 value
    ) internal virtual {}

    /// @dev Mints the burned tokens for the configured contracts and addresses.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function _doMintBurnerBurned(address account)
        internal
        virtual
        returns (uint256)
    {
        uint256 balance = getCurrentBurnerBurned();
        uint256 tokensLastBurned = lastBurnerBurned();
        if (balance <= tokensLastBurned) {
            revert NoTokensToMint();
        }
        uint256 tokens =
            (balance - tokensLastBurned) * mintBurnerRatio() / 10000;
        setLastBurnerBurned(balance);
        _mint(account, tokens);
        return tokens;
    }

    /// @notice Mints the burned tokens for the configured contracts and burner.
    /// @dev Mints the burned tokens for the configured contracts and burner.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintBurnerBurned()
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintBurnerBurned(sender, sender);
        tokens = _doMintBurnerBurned(sender);
        afterMintBurnerBurned(sender, tokens);
        return tokens;
    }

    /// @notice Mints the burned tokens for the configured contracts and burner.
    /// @dev Mints the burned tokens for the configured contracts and burner.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintBurnerBurnedFor(address account)
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintBurnerBurned(sender, account);
        tokens = _doMintBurnerBurned(account);
        afterMintBurnerBurned(account, tokens);
        return tokens;
    }
}
