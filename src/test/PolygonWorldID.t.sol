// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {PolygonWorldID} from "src/PolygonWorldID.sol";
import {SemaphoreTreeDepthValidator} from "src/utils/SemaphoreTreeDepthValidator.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title PolygonWorldIDTest
/// @author Worldcoin
/// @notice A test contract for PolygonWorldID
/// @dev The PolygonWorldID contract is deployed on Polygon PoS and is called by the StateBridge contract.
/// @dev This contract uses the Optimism CommonTest.t.sol tool suite to test the PolygonWorldID contract.
contract PolygonWorldIDTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                           WORLD ID                          ///
    ///////////////////////////////////////////////////////////////////
    /// @notice The PolygonWorldID contract
    PolygonWorldID internal id;

    /// @notice MarkleTree depth
    uint8 internal treeDepth = 16;

    /// @notice demo address
    address public alice = address(0x1111111);

    /// @notice fxChild contract address
    address public fxChild = address(0x2222222);

    function setUp() public {
        /// @notice Initialize the PolygonWorldID contract
        vm.prank(alice);
        id = new PolygonWorldID(treeDepth, fxChild);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "PolygonWorldID");
    }

    ///////////////////////////////////////////////////////////////////
    ///                            TESTS                            ///
    ///////////////////////////////////////////////////////////////////

    function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(!SemaphoreTreeDepthValidator.validate(actualTreeDepth));
        vm.expectRevert(abi.encodeWithSignature("UnsupportedTreeDepth(uint8)", actualTreeDepth));

        new PolygonWorldID(actualTreeDepth, fxChild);
    }

    /// @notice Checks that it is possible to get the tree depth the contract was initialized with.
    function testCanGetTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(SemaphoreTreeDepthValidator.validate(actualTreeDepth));

        id = new PolygonWorldID(actualTreeDepth, fxChild);

        // Test
        assert(id.getTreeDepth() == actualTreeDepth);
    }

    /// @notice Checks that calling the placeholder setRootHistoryExpiry function reverts.
    function testSetRootHistoryExpiryReverts(uint256 expiryTime) public {
        // Test
        vm.expectRevert(
            "PolygonWorldID: Root history expiry should only be set via the state bridge"
        );
        id.setRootHistoryExpiry(expiryTime);
    }
}
