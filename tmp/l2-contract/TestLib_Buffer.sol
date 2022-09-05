// Dependency file: contracts/libraries/utils/Lib_Buffer.sol

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

/**
 * @title Lib_Buffer
 * @dev This library implements a bytes32 storage array with some additional gas-optimized
 * functionality. In particular, it encodes its length as a uint40, and tightly packs this with an
 * overwritable "extra data" field so we can store more information with a single SSTORE.
 */
library Lib_Buffer {
    /*************
     * Libraries *
     *************/

    using Lib_Buffer for Buffer;

    /***********
     * Structs *
     ***********/

    struct Buffer {
        bytes32 context;
        mapping(uint256 => bytes32) buf;
    }

    struct BufferContext {
        // Stores the length of the array. Uint40 is way more elements than we'll ever reasonably
        // need in an array and we get an extra 27 bytes of extra data to play with.
        uint40 length;
        // Arbitrary extra data that can be modified whenever the length is updated. Useful for
        // squeezing out some gas optimizations.
        bytes27 extraData;
    }

    /**********************
     * Internal Functions *
     **********************/

    /**
     * Pushes a single element to the buffer.
     * @param _self Buffer to access.
     * @param _value Value to push to the buffer.
     * @param _extraData Global extra data.
     */
    function push(
        Buffer storage _self,
        bytes32 _value,
        bytes27 _extraData
    ) internal {
        BufferContext memory ctx = _self.getContext();

        _self.buf[ctx.length] = _value;

        // Bump the global index and insert our extra data, then save the context.
        ctx.length++;
        ctx.extraData = _extraData;
        _self.setContext(ctx);
    }

    /**
     * Pushes a single element to the buffer.
     * @param _self Buffer to access.
     * @param _value Value to push to the buffer.
     */
    function push(Buffer storage _self, bytes32 _value) internal {
        BufferContext memory ctx = _self.getContext();

        _self.push(_value, ctx.extraData);
    }

    /**
     * Retrieves an element from the buffer.
     * @param _self Buffer to access.
     * @param _index Element index to retrieve.
     * @return Value of the element at the given index.
     */
    function get(Buffer storage _self, uint256 _index) internal view returns (bytes32) {
        BufferContext memory ctx = _self.getContext();

        require(_index < ctx.length, "Index out of bounds.");

        return _self.buf[_index];
    }

    /**
     * Deletes all elements after (and including) a given index.
     * @param _self Buffer to access.
     * @param _index Index of the element to delete from (inclusive).
     * @param _extraData Optional global extra data.
     */
    function deleteElementsAfterInclusive(
        Buffer storage _self,
        uint40 _index,
        bytes27 _extraData
    ) internal {
        BufferContext memory ctx = _self.getContext();

        require(_index < ctx.length, "Index out of bounds.");

        // Set our length and extra data, save the context.
        ctx.length = _index;
        ctx.extraData = _extraData;
        _self.setContext(ctx);
    }

    /**
     * Deletes all elements after (and including) a given index.
     * @param _self Buffer to access.
     * @param _index Index of the element to delete from (inclusive).
     */
    function deleteElementsAfterInclusive(Buffer storage _self, uint40 _index) internal {
        BufferContext memory ctx = _self.getContext();
        _self.deleteElementsAfterInclusive(_index, ctx.extraData);
    }

    /**
     * Retrieves the current global index.
     * @param _self Buffer to access.
     * @return Current global index.
     */
    function getLength(Buffer storage _self) internal view returns (uint40) {
        BufferContext memory ctx = _self.getContext();
        return ctx.length;
    }

    /**
     * Changes current global extra data.
     * @param _self Buffer to access.
     * @param _extraData New global extra data.
     */
    function setExtraData(Buffer storage _self, bytes27 _extraData) internal {
        BufferContext memory ctx = _self.getContext();
        ctx.extraData = _extraData;
        _self.setContext(ctx);
    }

    /**
     * Retrieves the current global extra data.
     * @param _self Buffer to access.
     * @return Current global extra data.
     */
    function getExtraData(Buffer storage _self) internal view returns (bytes27) {
        BufferContext memory ctx = _self.getContext();
        return ctx.extraData;
    }

    /**
     * Sets the current buffer context.
     * @param _self Buffer to access.
     * @param _ctx Current buffer context.
     */
    function setContext(Buffer storage _self, BufferContext memory _ctx) internal {
        bytes32 context;
        uint40 length = _ctx.length;
        bytes27 extraData = _ctx.extraData;
        assembly {
            context := length
            context := or(context, extraData)
        }

        if (_self.context != context) {
            _self.context = context;
        }
    }

    /**
     * Retrieves the current buffer context.
     * @param _self Buffer to access.
     * @return Current buffer context.
     */
    function getContext(Buffer storage _self) internal view returns (BufferContext memory) {
        bytes32 context = _self.context;
        uint40 length;
        bytes27 extraData;
        assembly {
            length := and(
                context,
                0x000000000000000000000000000000000000000000000000000000FFFFFFFFFF
            )
            extraData := and(
                context,
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
            )
        }

        return BufferContext({ length: length, extraData: extraData });
    }
}


// Root file: contracts/test-libraries/utils/TestLib_Buffer.sol

pragma solidity ^0.8.9;

/* Library Imports */
// import { Lib_Buffer } from "contracts/libraries/utils/Lib_Buffer.sol";

/**
 * @title TestLib_Buffer
 */
contract TestLib_Buffer {
    using Lib_Buffer for Lib_Buffer.Buffer;
    using Lib_Buffer for Lib_Buffer.BufferContext;

    Lib_Buffer.Buffer internal buf;

    function push(bytes32 _value, bytes27 _extraData) public {
        buf.push(_value, _extraData);
    }

    function push(bytes32 _value) public {
        buf.push(_value);
    }

    function get(uint256 _index) public view returns (bytes32) {
        return buf.get(_index);
    }

    function deleteElementsAfterInclusive(uint40 _index) public {
        return buf.deleteElementsAfterInclusive(_index);
    }

    function deleteElementsAfterInclusive(uint40 _index, bytes27 _extraData) public {
        return buf.deleteElementsAfterInclusive(_index, _extraData);
    }

    function getLength() public view returns (uint40) {
        return buf.getLength();
    }

    function setExtraData(bytes27 _extraData) public {
        return buf.setExtraData(_extraData);
    }

    function getExtraData() public view returns (bytes27) {
        return buf.getExtraData();
    }

    function getContext() public view returns (Lib_Buffer.BufferContext memory) {
        return buf.getContext();
    }

    function setContext(uint40 _index, bytes27 _extraData) public {
        Lib_Buffer.BufferContext memory _ctx = Lib_Buffer.BufferContext({
            length: _index,
            extraData: _extraData
        });
        return buf.setContext(_ctx);
    }
}
