// Dependency file: contracts/libraries/utils/Lib_Bytes32Utils.sol

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

/**
 * @title Lib_Byte32Utils
 */
library Lib_Bytes32Utils {
    /**********************
     * Internal Functions *
     **********************/

    /**
     * Converts a bytes32 value to a boolean. Anything non-zero will be converted to "true."
     * @param _in Input bytes32 value.
     * @return Bytes32 as a boolean.
     */
    function toBool(bytes32 _in) internal pure returns (bool) {
        return _in != 0;
    }

    /**
     * Converts a boolean to a bytes32 value.
     * @param _in Input boolean value.
     * @return Boolean as a bytes32.
     */
    function fromBool(bool _in) internal pure returns (bytes32) {
        return bytes32(uint256(_in ? 1 : 0));
    }

    /**
     * Converts a bytes32 value to an address. Takes the *last* 20 bytes.
     * @param _in Input bytes32 value.
     * @return Bytes32 as an address.
     */
    function toAddress(bytes32 _in) internal pure returns (address) {
        return address(uint160(uint256(_in)));
    }

    /**
     * Converts an address to a bytes32.
     * @param _in Input address value.
     * @return Address as a bytes32.
     */
    function fromAddress(address _in) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_in)));
    }
}


// Root file: contracts/test-libraries/utils/TestLib_Bytes32Utils.sol

pragma solidity ^0.8.9;

/* Library Imports */
// import { Lib_Bytes32Utils } from "contracts/libraries/utils/Lib_Bytes32Utils.sol";

/**
 * @title TestLib_Byte32Utils
 */
contract TestLib_Bytes32Utils {
    function toBool(bytes32 _in) public pure returns (bool _out) {
        return Lib_Bytes32Utils.toBool(_in);
    }

    function fromBool(bool _in) public pure returns (bytes32 _out) {
        return Lib_Bytes32Utils.fromBool(_in);
    }

    function toAddress(bytes32 _in) public pure returns (address _out) {
        return Lib_Bytes32Utils.toAddress(_in);
    }

    function fromAddress(address _in) public pure returns (bytes32 _out) {
        return Lib_Bytes32Utils.fromAddress(_in);
    }
}
