// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibDescribedByMeta, MetadataMismatch} from "src/lib/LibDescribedByMeta.sol";
import {IDescribedByMetaV1} from "src/interface/unstable/IDescribedByMetaV1.sol";
import {IMetaBoardV1} from "src/interface/IMetaBoardV1.sol";
import {MetaBoard} from "src/concrete/MetaBoard.sol";
import {META_MAGIC_NUMBER_V1} from "src/interface/IMetaV1.sol";

contract TestDescribedByMetaV1 is IDescribedByMetaV1 {
    bytes32 public immutable expected;

    constructor(bytes memory meta) {
        expected = keccak256(meta);
    }

    function describedByMetaV1() external view override returns (bytes32) {
        return expected;
    }
}

contract LibDescribedByMetaEmitForDescribedAddressTest is Test {
    function externalEmitForDescribedAddress(IMetaBoardV1 metaboard, IDescribedByMetaV1 described, bytes memory meta)
        external
    {
        LibDescribedByMeta.emitForDescribedAddress(metaboard, described, meta);
    }

    function testEmitForDescribedAddressHappy(bytes memory metaData) external {
        IMetaBoardV1 metaboard = new MetaBoard();

        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, metaData);

        IDescribedByMetaV1 described = new TestDescribedByMetaV1(meta);

        LibDescribedByMeta.emitForDescribedAddress(metaboard, described, meta);
    }

    function testEmitForDescribedAddressMismatch(bytes memory metaData, bytes memory expectedMetaData) external {
        IMetaBoardV1 metaboard = new MetaBoard();

        bytes memory meta = abi.encodePacked(META_MAGIC_NUMBER_V1, metaData);
        bytes memory expectedMeta = abi.encodePacked(META_MAGIC_NUMBER_V1, expectedMetaData);

        IDescribedByMetaV1 described = new TestDescribedByMetaV1(expectedMeta);

        vm.assume(keccak256(meta) != keccak256(expectedMeta));
        vm.expectRevert(
            abi.encodeWithSelector(MetadataMismatch.selector, described, keccak256(expectedMeta), keccak256(meta))
        );

        this.externalEmitForDescribedAddress(metaboard, described, meta);
    }
}
