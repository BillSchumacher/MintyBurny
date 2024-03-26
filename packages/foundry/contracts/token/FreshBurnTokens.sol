// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {MultiTokenMintRegistry} from "./common/MultiTokenMintRegistry.sol";
import {MultiTokenBurnRegistry} from "./common/MultiTokenBurnRegistry.sol";

/// @title Test registries.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnTokens is MultiTokenBurnRegistry, MultiTokenMintRegistry {}
