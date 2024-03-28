// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrorsUpgradeable.sol";

/// @title A smart contract that checks for burned tokens and mints new tokens based on the burned tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfBurnUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20ProofOfBurn
    struct ERC20ProofOfBurnStorage {
        uint256 _lastBurned;
        address[] _burnAddresses;
        address[] _burnContracts;
    }

    bytes32 private constant ERC20ProofOfBurnStorageLocation =
        0x9273e854661a8ddc81587b87750615dd3820240b8fca88a3aebc69cad0f94900;

    function _getERC20ProofOfBurnStorage()
        private
        pure
        returns (ERC20ProofOfBurnStorage storage $)
    {
        assembly {
            $.slot := ERC20ProofOfBurnStorageLocation
        }
    }

    function __ERC20ProofOfBurn_init(
        address[] memory burnAddresses_,
        address[] memory burnContracts_
    ) public virtual onlyInitializing {
        __ERC20ProofOfBurn_init_unchained(burnAddresses_, burnContracts_);
    }

    function __ERC20ProofOfBurn_init_unchained(
        address[] memory burnAddresses_,
        address[] memory burnContracts_
    ) internal onlyInitializing {
        ERC20ProofOfBurnStorage storage $ = _getERC20ProofOfBurnStorage();
        $._burnAddresses = burnAddresses_;
        $._burnContracts = burnContracts_;
    }

    /// @notice Get the last amount of tokens that were burned.
    /// @dev Returns the last amount of tokens that were burned.
    /// @return (uint256) - the last amount of tokens that were burned.
    function lastBurned() public view returns (uint256) {
        ERC20ProofOfBurnStorage storage $ = _getERC20ProofOfBurnStorage();
        return $._lastBurned;
    }

    /// @dev Set the last amount of tokens that were burned. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were burned.
    function setLastBurned(uint256 value) internal virtual {
        ERC20ProofOfBurnStorage storage $ = _getERC20ProofOfBurnStorage();
        $._lastBurned = value;
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
        ERC20ProofOfBurnStorage storage $ = _getERC20ProofOfBurnStorage();
        address[] memory eligibleBurnAddresses = $._burnAddresses;
        address[] memory eligibleBurnContracts = $._burnContracts;
        uint256 addressLength = eligibleBurnAddresses.length;
        uint256 contractLength = eligibleBurnContracts.length;
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
