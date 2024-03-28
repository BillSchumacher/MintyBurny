// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20MintRegistryUpgradeable} from
    "../extensions/ERC20MintRegistryUpgradeable.sol";
import {ERC20BurnRegistryUpgradeable} from
    "../extensions/ERC20BurnRegistryUpgradeable.sol";
import {ERC20ProofOfBurnUpgradeable} from
    "../extensions/ERC20ProofOfBurnUpgradeable.sol";
import {ERC20CappedUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import {ERC20ProofOfBurnerUpgradeable} from
    "../extensions/ERC20ProofOfBurnerUpgradeable.sol";
import {ERC20ProofOfMintUpgradeable} from
    "../extensions/ERC20ProofOfMintUpgradeable.sol";
import {ERC20ProofOfMinterUpgradeable} from
    "../extensions/ERC20ProofOfMinterUpgradeable.sol";
import {IERC20CustomErrorsUpgradeable} from
    "../extensions/IERC20CustomErrorsUpgradeable.sol";

/// @title Example implementation contract for extensions.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract ERC20BurntMintyBurnyUpgradeable is
    Initializable,
    ERC20ProofOfBurnUpgradeable,
    ERC20ProofOfBurnerUpgradeable,
    ERC20ProofOfMintUpgradeable,
    ERC20ProofOfMinterUpgradeable,
    ERC20MintRegistryUpgradeable,
    ERC20BurnRegistryUpgradeable,
    ERC20CappedUpgradeable
{
    function initialize(
        address[] memory burnAddresses,
        address[] memory contractAddresses
    ) public initializer {
        __ERC20BurntMintyBurny_init(burnAddresses, contractAddresses);
        mint(1000000 * 10 ** decimals());
        burn(500000 * 10 ** decimals());
    }

    function __ERC20BurntMintyBurny_init(
        address[] memory burnAddresses,
        address[] memory contractAddresses
    ) public virtual onlyInitializing {
        __ERC20BurntMintyBurny_init_unchained(burnAddresses, contractAddresses);
        __ERC20_init("MintyBurny", "MB");
        __ERC20Capped_init(2 ** 254);
        __ERC20ProofOfBurn_init(burnAddresses, contractAddresses);
        __ERC20ProofOfBurner_init(contractAddresses);
        __ERC20ProofOfMint_init(contractAddresses);
        __ERC20ProofOfMinter_init(contractAddresses);
    }

    function __ERC20BurntMintyBurny_init_unchained(
        address[] memory burnAddresses,
        address[] memory contractAddresses
    ) internal onlyInitializing {
        // ERC20MintRegistryStorage storage $ = _getERC20MintRegistryStorage();
        // ERC20BurnRegistryStorage storage _ = _getERC20BurnRegistryStorage();
    }

    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20BurntMintyBurny
    struct ERC20BurntMintyBurnyStorage {
        uint256 unused;
    }

    bytes32 private constant ERC20BurntMintyBurnyStorageLocation =
        0xaa0467f9ea10f0630e4205930612d54e5086cfd131b49d0d3ee11f132812d200;

    function _getMultiTokenBurnRegistryStorage()
        private
        pure
        returns (ERC20BurntMintyBurnyStorage storage $)
    {
        assembly {
            $.slot := ERC20BurntMintyBurnyStorageLocation
        }
    }

    /// @inheritdoc ERC20ProofOfBurnUpgradeable
    function mintRatio()
        public
        pure
        override(
            ERC20ProofOfBurnUpgradeable,
            ERC20ProofOfBurnerUpgradeable,
            ERC20ProofOfMintUpgradeable,
            ERC20ProofOfMinterUpgradeable
        )
        returns (uint256)
    {
        // Just for coverage...
        ERC20ProofOfBurnUpgradeable.mintRatio();
        ERC20ProofOfBurnerUpgradeable.mintRatio();
        ERC20ProofOfMintUpgradeable.mintRatio();
        ERC20ProofOfMinterUpgradeable.mintRatio();
        return 5000;
    }

    /// @inheritdoc ERC20Upgradeable
    function balanceOf(address account)
        public
        view
        virtual
        override(ERC20Upgradeable, ERC20BurnRegistryUpgradeable)
        returns (uint256)
    {
        return ERC20BurnRegistryUpgradeable.balanceOf(account);
    }

    /// @inheritdoc ERC20Upgradeable
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable, ERC20CappedUpgradeable) {
        if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply + value > maxSupply) {
                revert ERC20CappedUpgradeable.ERC20ExceededCap(
                    supply, maxSupply
                );
            }
        }
        ERC20Upgradeable._update(from, to, value);
    }

    /// @notice Allows the token to receive ether.
    receive() external payable {}

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public virtual {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) {
            revert IERC20CustomErrorsUpgradeable.ERC20TransferFailed(to, value);
        }
    }
}
