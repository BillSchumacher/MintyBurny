// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IMultiTokenBurnRegistry} from "./common/IMultiTokenBurnRegistry.sol";
import {IMultiTokenMintRegistry} from "./common/IMultiTokenMintRegistry.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20/extensions/ERC20ProofOfMint.sol";

/// @title An ERC20 token supporting an external registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract ChillyDog is ERC20, Ownable, ERC20ProofOfMint, ERC20Burnable {
    address private _registry;
    uint256 private _lastFee;
    uint256 private _zeroAddress;
    uint256 private _mintFee = 0.01 ether;
    string private _description;

    error InsufficientMintFee(uint256 mintFee, uint256 msgValue);

    constructor(
        address registry_,
        address[] memory contractAddresses
    )
        ERC20("Chilly Dog", "BRRRR")
        Ownable(msg.sender)
        ERC20ProofOfMint(contractAddresses)
    {
        _registry = registry_;
    }

    /// @inheritdoc ERC20
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (account == address(0)) return _zeroAddress;
        return ERC20.balanceOf(account);
    }

    /// @notice Get the description of the token.
    /// @dev Returns the description of the token.
    /// @return (string) - the description of the token.
    function description() public view returns (string memory) {
        return _description;
    }

    /// @notice Set the description of the token.
    /// @dev Set the description of the token.
    /// @param desc (string) - the description of the token.
    function setDesc(string calldata desc) public onlyOwner {
        _description = desc;
    }

    /// @inheritdoc ERC20
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20) {
        ERC20._update(from, to, value);
        if (to == address(0)) {
            _zeroAddress += value;
            this._updateBurnRegistry(from, value);
        }
        if (from == address(0)) {
            this._updateMintRegistry(to, value);
        }
    }

    /// @notice Get the current fee to mint tokens.
    /// @dev Returns the current fee to mint tokens.
    /// @return (uint256) - the current fee to mint tokens.
    function getMintFee() public view returns (uint256) {
        return _mintFee;
    }

    /// @inheritdoc ERC20ProofOfMint
    function beforeMintMinted(
        address sender,
        address account
    ) internal override {
        uint256 currentMintFee = _mintFee;
        uint256 sentValue = msg.value;
        if (sentValue < currentMintFee) {
            revert InsufficientMintFee(currentMintFee, sentValue);
        }
        _mintFee = currentMintFee * 1001 / 1000;
        sender;
        account;
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.beforeMintMintedbeforeMintMinted
    function _updateBurnRegistry(address account, uint256 value) external {
        if (msg.sender != address(this)) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        //_registry.call(abi.encodeWithSignature("updateBurnRegistry(address,uint256)", account, value));
        IMultiTokenBurnRegistry(_registry).updateBurnRegistry(account, value);
    }

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function _updateMintRegistry(address account, uint256 value) external {
        if (msg.sender != address(this)) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        //_registry.call(abi.encodeWithSignature("updateMintRegistry(address,uint256)", account, value));
        IMultiTokenMintRegistry(_registry).updateMintRegistry(account, value);
    }

    /// @notice Allows the token to receive ether.
    receive() external payable {}

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public onlyOwner {
        uint256 value = address(this).balance;
        address to = owner();
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
