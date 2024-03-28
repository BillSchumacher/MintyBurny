// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrorsUpgradeable.sol";
import {ERC20MintRegistryUpgradeable} from "./ERC20MintRegistryUpgradeable.sol";

/// @title A smart contract that checks for minted tokens and mints new tokens based on the minted tokens.
/// @custom:requires minterContracts to implement ERC20MintRegistry
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfMinterUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20ProofOfMinter
    struct ERC20ProofOfMinterStorage {
        mapping(address => uint256) _lastMinterMinted;
        address[] _minterContracts;
    }

    bytes32 private constant ERC20ProofOfMinterStorageLocation =
        0xf0006787642da1eec81add553091eb73f193bb20ce1fe8f1709fee8aa5b58100;

    function _getERC20ProofOfMinterStorage()
        private
        pure
        returns (ERC20ProofOfMinterStorage storage $)
    {
        assembly {
            $.slot := ERC20ProofOfMinterStorageLocation
        }
    }

    function __ERC20ProofOfMinter_init(address[] memory minterContracts_)
        public
        virtual
        onlyInitializing
    {
        __ERC20ProofOfMinter_init_unchained(minterContracts_);
    }

    function __ERC20ProofOfMinter_init_unchained(
        address[] memory minterContracts_
    ) internal onlyInitializing {
        ERC20ProofOfMinterStorage storage $ = _getERC20ProofOfMinterStorage();
        $._minterContracts = minterContracts_;
    }

    /// @notice Get the last amount of tokens that were minted.
    /// @dev Returns the last amount of tokens that were minted.
    /// @return (uint256) - the last amount of tokens that were minted.
    function lastMinterMinted() public view returns (uint256) {
        ERC20ProofOfMinterStorage storage $ = _getERC20ProofOfMinterStorage();
        return $._lastMinterMinted[_msgSender()];
    }

    /// @dev Set the last amount of tokens that were minted. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were minted.
    function setLastMinterMinted(uint256 value) internal virtual {
        ERC20ProofOfMinterStorage storage $ = _getERC20ProofOfMinterStorage();
        $._lastMinterMinted[_msgSender()] = value;
    }

    /// @notice Get the amount of tokens eligible to be minted.
    /// @dev Returns the amount of tokens eligible to be minted.
    /// @return balance (uint256) - the amount of tokens eligible to be minted.
    function getCurrentMinterMinted()
        public
        payable
        virtual
        returns (uint256 balance)
    {
        ERC20ProofOfMinterStorage storage $ = _getERC20ProofOfMinterStorage();
        address[] memory eligibleMinterContracts = $._minterContracts;
        uint256 contractLength = eligibleMinterContracts.length;
        address sender = _msgSender();
        for (uint256 i; i < contractLength; ++i) {
            ERC20MintRegistryUpgradeable tokenContract =
                ERC20MintRegistryUpgradeable(eligibleMinterContracts[i]);
            balance += tokenContract.mintedBy(sender);
        }
        return balance;
    }

    /// @notice Get the ratio of tokens to mint.
    /// @dev Returns the ratio of tokens to mint. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function mintRatio() public pure virtual returns (uint256) {
        return 5000;
    }

    /// @notice Get the ratio of tokens to mint for ProofOfMinter.
    /// @dev Returns the ratio of tokens to mint for ProofOfMinter. Override to customize. Divided by 10000. 5000 = 0.5 (default)
    /// @return (uint256) - the ratio of tokens to mint.
    function mintMinterRatio() public view virtual returns (uint256) {
        return mintRatio();
    }

    /// @dev Handle access control, accounting, and any conditions here before minting, revert if failed.
    /// @param sender (address) - the address of the sender.
    /// @param account (address) - the address of the account.
    function beforeMintMinterMinted(
        address sender,
        address account
    ) internal virtual {}

    /// @dev Update the mint registry or perform other accounting. Override to customize.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens minted.
    function afterMintMinterMinted(
        address account,
        uint256 value
    ) internal virtual {}

    /// @dev Mints the minted tokens for the configured contracts and sender.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function _doMintMinterMinted(address account)
        internal
        virtual
        returns (uint256)
    {
        uint256 balance = getCurrentMinterMinted();
        uint256 tokensLastMinted = lastMinterMinted();
        if (balance <= tokensLastMinted) {
            revert NoTokensToMint();
        }
        uint256 tokens =
            (balance - tokensLastMinted) * mintMinterRatio() / 10000;
        setLastMinterMinted(balance);
        _mint(account, tokens);
        return tokens;
    }

    /// @notice Mints the minted tokens for the configured contracts and sender.
    /// @dev Mints the minted tokens for the configured contracts and sender.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintMinterMinted()
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintMinterMinted(sender, sender);
        tokens = _doMintMinterMinted(sender);
        afterMintMinterMinted(sender, tokens);
        return tokens;
    }

    /// @notice Mints the minted tokens for the configured contracts and sender.
    /// @dev Mints the minted tokens for the configured contracts and sender.
    /// @return tokens (uint256) - the amount of tokens minted.
    function mintMinterMintedFor(address account)
        public
        payable
        virtual
        returns (uint256 tokens)
    {
        address sender = _msgSender();
        beforeMintMinterMinted(sender, account);
        tokens = _doMintMinterMinted(account);
        afterMintMinterMinted(account, tokens);
        return tokens;
    }
}
