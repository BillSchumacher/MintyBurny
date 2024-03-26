// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./ERC20MintyBurnyErrors.sol";

/// @title A smart contract that checks for minted tokens and mints new tokens based on the minted tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ProofOfMint is Context, ERC20 {
    uint256 private _lastMinted;
    address[] internal _mintContracts;

    constructor(address[] memory mintContracts) {
        _mintContracts = mintContracts;
    }

    /// @notice Get the last amount of tokens that were minted.
    /// @dev Returns the last amount of tokens that were minted.
    /// @return (uint256) - the last amount of tokens that were minted.
    function lastMinted() public view returns (uint256) {
        return _lastMinted;
    }

    /// @dev Set the last amount of tokens that were minted. Override to customize.
    /// @param value (uint256) - the last amount of tokens that were minted.
    function setLastMinted(uint256 value) internal virtual {
        _lastMinted = value;
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
        address[] memory eligibleMintContracts = _mintContracts;
        uint256 contractLength = _mintContracts.length;
        for (uint256 i; i < contractLength; ++i) {
            ERC20 tokenContract = ERC20(eligibleMintContracts[i]);
            balance += tokenContract.totalSupply();
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
