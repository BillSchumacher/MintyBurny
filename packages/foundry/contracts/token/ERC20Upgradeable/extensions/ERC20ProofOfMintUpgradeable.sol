// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrorsUpgradeable.sol";

/// @title A smart contract that checks for minted tokens and mints new tokens based on the minted tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfMintUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20ProofOfMint
    struct ERC20ProofOfMintStorage {
        uint256 _lastMinted;
        address[] _mintContracts;
    }

    bytes32 private constant ERC20ProofOfMintStorageLocation =
        0xf0cbf2adbe92869c9ca4deb301ceed5c96870a50bb9cd39020244a0daf11b600;

    function _getERC20ProofOfMintStorage()
        private
        pure
        returns (ERC20ProofOfMintStorage storage $)
    {
        assembly {
            $.slot := ERC20ProofOfMintStorageLocation
        }
    }

    function __ERC20ProofOfMint_init(address[] memory mintContracts_)
        public
        virtual
        onlyInitializing
    {
        __ERC20ProofOfMint_init_unchained(mintContracts_);
    }

    function __ERC20ProofOfMint_init_unchained(address[] memory mintContracts_)
        internal
        onlyInitializing
    {
        ERC20ProofOfMintStorage storage $ = _getERC20ProofOfMintStorage();
        $._mintContracts = mintContracts_;
    }

    /// @notice Get the last amount of tokens that were minted.
    /// @dev Returns the last amount of tokens that were minted.
    /// @return (uint256) - the last amount of tokens that were minted.
    function lastMinted() public view returns (uint256) {
        ERC20ProofOfMintStorage storage $ = _getERC20ProofOfMintStorage();
        return $._lastMinted;
    }

    /// @dev Set the last amount of tokens that were minted. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were minted.
    function setLastMinted(uint256 value) internal virtual {
        ERC20ProofOfMintStorage storage $ = _getERC20ProofOfMintStorage();
        $._lastMinted = value;
    }

    /// @notice Get the amount of tokens eligible to be minted.
    /// @dev Returns the amount of tokens eligible to be minted.
    /// @return balance (uint256) - the amount of tokens eligible to be minted.
    function getCurrentMinted()
        public
        payable
        virtual
        returns (uint256 balance)
    {
        ERC20ProofOfMintStorage storage $ = _getERC20ProofOfMintStorage();
        address[] memory eligibleMintContracts = $._mintContracts;
        uint256 contractLength = eligibleMintContracts.length;
        for (uint256 i; i < contractLength;) {
            ERC20Upgradeable tokenContract =
                ERC20Upgradeable(eligibleMintContracts[i]);
            balance += tokenContract.totalSupply();
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

    /// @notice Get the ratio of tokens to mint for ProofOfMint.
    /// @dev Returns the ratio of tokens to mint for ProofOfMint. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function mintedRatio() public view virtual returns (uint256) {
        return mintRatio();
    }

    /// @dev Handle access control, accounting, and any conditions here before minting, revert if failed.
    /// @param sender (address) - the address of the sender.
    /// @param account (address) - the address of the account.
    function beforeMintMinted(
        address sender,
        address account
    ) internal virtual {}

    /// @dev Update the mint registry or perform other accounting. Override to customize.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens minted.
    function afterMintMinted(address account, uint256 value) internal virtual {}

    /// @dev Mints the minted tokens for the configured contracts and addresses.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function _doMintMinted(address account)
        internal
        virtual
        returns (uint256)
    {
        uint256 balance = getCurrentMinted();
        uint256 tokensLastMinted = lastMinted();
        if (balance <= tokensLastMinted) {
            revert NoTokensToMint();
        }
        uint256 tokens = (balance - tokensLastMinted) * mintedRatio() / 10000;
        setLastMinted(balance);
        _mint(account, tokens);
        return tokens;
    }

    /// @notice Mints the minted tokens for the configured contracts.
    /// @dev Mints the minted tokens for the configured contracts.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintMinted() public payable virtual returns (uint256 tokens) {
        address sender = _msgSender();
        beforeMintMinted(sender, sender);
        tokens = _doMintMinted(sender);
        afterMintMinted(sender, tokens);
        return tokens;
    }

    /// @notice Mints the minted tokens for the configured contracts.
    /// @dev Mints the minted tokens for the configured contracts.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintMintedFor(address account)
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintMinted(sender, account);
        tokens = _doMintMinted(account);
        afterMintMinted(account, tokens);
        return tokens;
    }
}
