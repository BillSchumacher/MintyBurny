// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20BurnRegistryUpgradeable} from "./ERC20BurnRegistryUpgradeable.sol";
import {NoTokensToMint} from "./ERC20MintyBurnyErrorsUpgradeable.sol";

/// @title A smart contract that checks for burned tokens and mints new tokens based on the burned tokens.
/// @custom:requires burnerContracts to implement ERC20BurnRegistry
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfBurnerUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20ProofOfBurner
    struct ERC20ProofOfBurnerStorage {
        mapping(address => uint256) _lastBurnerBurned;
        address[] _burnerContracts;
    }

    // keccak256(abi.encode(uint256(keccak256("MintyBurny.storage.ERC20ProofOfBurner")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20ProofOfBurnerStorageLocation =
        0x8dc2656c4fe32c77d2764b43e6c01ffc01299f3c2409f832315ec0a06b3a6100;

    function _getERC20ProofOfBurnerStorage()
        private
        pure
        returns (ERC20ProofOfBurnerStorage storage $)
    {
        assembly {
            $.slot := ERC20ProofOfBurnerStorageLocation
        }
    }

    function __ERC20ProofOfBurner_init(address[] memory burnerContracts_)
        public
        virtual
        onlyInitializing
    {
        __ERC20ProofOfBurner_init_unchained(burnerContracts_);
    }

    function __ERC20ProofOfBurner_init_unchained(
        address[] memory burnerContracts_
    ) internal onlyInitializing {
        ERC20ProofOfBurnerStorage storage $ = _getERC20ProofOfBurnerStorage();
        $._burnerContracts = burnerContracts_;
    }

    /// @notice Get the last amount of tokens that were burned.
    /// @dev Returns the last amount of tokens that were burned.
    /// @return (uint256) - the last amount of tokens that were burned.
    function lastBurnerBurned() public view returns (uint256) {
        ERC20ProofOfBurnerStorage storage $ = _getERC20ProofOfBurnerStorage();
        return $._lastBurnerBurned[_msgSender()];
    }

    /// @dev Set the last amount of tokens that were burned. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were burned.
    function setLastBurnerBurned(uint256 value) internal virtual {
        ERC20ProofOfBurnerStorage storage $ = _getERC20ProofOfBurnerStorage();
        $._lastBurnerBurned[_msgSender()] = value;
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
        ERC20ProofOfBurnerStorage storage $ = _getERC20ProofOfBurnerStorage();
        address[] memory eligibleBurnerContracts = $._burnerContracts;
        uint256 contractLength = eligibleBurnerContracts.length;
        address sender = _msgSender();
        for (uint256 i; i < contractLength; ++i) {
            ERC20BurnRegistryUpgradeable tokenContract =
                ERC20BurnRegistryUpgradeable(eligibleBurnerContracts[i]);
            balance += tokenContract.burnedFrom(sender);
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
