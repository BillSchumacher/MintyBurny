// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";

contract TestMultiMintBurnUpgradeableTest is Test {
    function setUp() public {}

    function testMultiTokenBurnRegistryStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(
                        keccak256("MintyBurny.storage.MultiTokenBurnRegistry")
                    ) - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0x8d7dd2605cd348455246d20287b62394203b2c84a04b5d85f103846a6bc7ee00
        );
    }

    function testMultiTokenMintRegistryStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(
                        keccak256("MintyBurny.storage.MultiTokenMintRegistry")
                    ) - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0x9a1c1e808f2bfa896c780520d91388311f35c67fdad8cc083afbd9d384d84100
        );
    }

    function testERC20BurnRegistryStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.ERC20BurnRegistry"))
                        - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0xf15fcfbf1c887e2d534832e4499f218738b8a22bff40e56a09c0ae588c22af00
        );
    }

    function testERC20ProofOfBurnStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.ERC20ProofOfBurn"))
                        - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0x9273e854661a8ddc81587b87750615dd3820240b8fca88a3aebc69cad0f94900
        );
    }

    function testERC20ProofOfBurnerStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.ERC20ProofOfBurner"))
                        - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0x8dc2656c4fe32c77d2764b43e6c01ffc01299f3c2409f832315ec0a06b3a6100
        );
    }

    function testERC20ProofOfMintStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.ERC20ProofOfMint"))
                        - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0xf0cbf2adbe92869c9ca4deb301ceed5c96870a50bb9cd39020244a0daf11b600
        );
    }

    function testERC20ProofOfMinterStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.ERC20ProofOfMinter"))
                        - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0xf0006787642da1eec81add553091eb73f193bb20ce1fe8f1709fee8aa5b58100
        );
    }

    function testERC20BurntMintyBurnyStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(
                        keccak256("MintyBurny.storage.ERC20BurntMintyBurny")
                    ) - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0xaa0467f9ea10f0630e4205930612d54e5086cfd131b49d0d3ee11f132812d200
        );
    }

    function testFreshBurnTokenStorageLocation() public pure {
        assertEq(
            keccak256(
                abi.encode(
                    uint256(keccak256("MintyBurny.storage.FreshBurnToken")) - 1
                )
            ) & ~bytes32(uint256(0xff)),
            0x2ae22741ee4c6304928a7cc01a2d5b2045521c8980d4420f4889dccbaaf6bd00
        );
    }
}
