// Dependency file: contracts/standards/AddressAliasHelper.sol

// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2019-2021, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// pragma solidity ^0.8.7;

library AddressAliasHelper {
    uint160 constant offset = uint160(0x1111000000000000000000000000000000001111);

    /// @notice Utility function that converts the address in the L1 that submitted a tx to
    /// the inbox to the msg.sender viewed in the L2
    /// @param l1Address the address in the L1 that triggered the tx to L2
    /// @return l2Address L2 address as viewed in msg.sender
    function applyL1ToL2Alias(address l1Address) internal pure returns (address l2Address) {
        unchecked {
            l2Address = address(uint160(l1Address) + offset);
        }
    }

    /// @notice Utility function that converts the msg.sender viewed in the L2 to the
    /// address in the L1 that submitted a tx to the inbox
    /// @param l2Address L2 address as viewed in msg.sender
    /// @return l1Address the address in the L1 that triggered the tx to L2
    function undoL1ToL2Alias(address l2Address) internal pure returns (address l1Address) {
        unchecked {
            l1Address = address(uint160(l2Address) - offset);
        }
    }
}


// Dependency file: contracts/libraries/bridge/Lib_CrossDomainUtils.sol

// pragma solidity ^0.8.9;

/**
 * @title Lib_CrossDomainUtils
 */
library Lib_CrossDomainUtils {
    /**
     * Generates the correct cross domain calldata for a message.
     * @param _target Target contract address.
     * @param _sender Message sender address.
     * @param _message Message to send to the target.
     * @param _messageNonce Nonce for the provided message.
     * @return ABI encoded cross domain calldata.
     */
    function encodeXDomainCalldata(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "relayMessage(address,address,bytes,uint256)",
                _target,
                _sender,
                _message,
                _messageNonce
            );
    }
}


// Dependency file: contracts/libraries/constants/Lib_DefaultValues.sol

// pragma solidity ^0.8.9;

/**
 * @title Lib_DefaultValues
 */
library Lib_DefaultValues {
    // The default x-domain message sender being set to a non-zero value makes
    // deployment a bit more expensive, but in exchange the refund on every call to
    // `relayMessage` by the L1 and L2 messengers will be higher.
    address internal constant DEFAULT_XDOMAIN_SENDER = 0x000000000000000000000000000000000000dEaD;
}


// Dependency file: contracts/libraries/constants/Lib_PredeployAddresses.sol

// pragma solidity ^0.8.9;

/**
 * @title Lib_PredeployAddresses
 */
library Lib_PredeployAddresses {
    address internal constant L2_TO_L1_MESSAGE_PASSER = 0x4200000000000000000000000000000000000000;
    address internal constant L1_MESSAGE_SENDER = 0x4200000000000000000000000000000000000001;
    address internal constant DEPLOYER_WHITELIST = 0x4200000000000000000000000000000000000002;
    address payable internal constant OVM_ETH = payable(0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000);
    address internal constant L2_CROSS_DOMAIN_MESSENGER =
        0x4200000000000000000000000000000000000007;
    address internal constant LIB_ADDRESS_MANAGER = 0x4200000000000000000000000000000000000008;
    address internal constant PROXY_EOA = 0x4200000000000000000000000000000000000009;
    address internal constant L2_STANDARD_BRIDGE = 0x4200000000000000000000000000000000000010;
    address internal constant SEQUENCER_FEE_WALLET = 0x4200000000000000000000000000000000000011;
    address internal constant L2_STANDARD_TOKEN_FACTORY =
        0x4200000000000000000000000000000000000012;
    address internal constant L1_BLOCK_NUMBER = 0x4200000000000000000000000000000000000013;
}


// Dependency file: contracts/libraries/bridge/ICrossDomainMessenger.sol

// pragma solidity >0.5.0 <0.9.0;

/**
 * @title ICrossDomainMessenger
 */
interface ICrossDomainMessenger {
    /**********
     * Events *
     **********/

    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit
    );
    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);

    /*************
     * Variables *
     *************/

    function xDomainMessageSender() external view returns (address);

    /********************
     * Public Functions *
     ********************/

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external;
}


// Dependency file: contracts/L2/messaging/IL2CrossDomainMessenger.sol

// pragma solidity ^0.8.9;

/* Interface Imports */
// import { ICrossDomainMessenger } from "contracts/libraries/bridge/ICrossDomainMessenger.sol";

/**
 * @title IL2CrossDomainMessenger
 */
interface IL2CrossDomainMessenger is ICrossDomainMessenger {
    /********************
     * Public Functions *
     ********************/

    /**
     * Relays a cross domain message to a contract.
     * @param _target Target contract address.
     * @param _sender Message sender address.
     * @param _message Message to send to the target.
     * @param _messageNonce Nonce for the provided message.
     */
    function relayMessage(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce
    ) external;
}


// Dependency file: contracts/L2/predeploys/iOVM_L2ToL1MessagePasser.sol

// pragma solidity ^0.8.9;

/**
 * @title iOVM_L2ToL1MessagePasser
 */
interface iOVM_L2ToL1MessagePasser {
    /**********
     * Events *
     **********/

    event L2ToL1Message(uint256 _nonce, address _sender, bytes _data);

    /********************
     * Public Functions *
     ********************/

    function passMessageToL1(bytes calldata _message) external;
}


// Root file: contracts/L2/messaging/L2CrossDomainMessenger.sol

pragma solidity ^0.8.9;

/* Library Imports */
// import { AddressAliasHelper } from "contracts/standards/AddressAliasHelper.sol";
// import { Lib_CrossDomainUtils } from "contracts/libraries/bridge/Lib_CrossDomainUtils.sol";
// import { Lib_DefaultValues } from "contracts/libraries/constants/Lib_DefaultValues.sol";
// import { Lib_PredeployAddresses } from "contracts/libraries/constants/Lib_PredeployAddresses.sol";

/* Interface Imports */
// import { IL2CrossDomainMessenger } from "contracts/L2/messaging/IL2CrossDomainMessenger.sol";
// import { iOVM_L2ToL1MessagePasser } from "contracts/L2/predeploys/iOVM_L2ToL1MessagePasser.sol";

/**
 * @title L2CrossDomainMessenger
 * @dev The L2 Cross Domain Messenger contract sends messages from L2 to L1, and is the entry point
 * for L2 messages sent via the L1 Cross Domain Messenger.
 *
 */
contract L2CrossDomainMessenger is IL2CrossDomainMessenger {
    /*************
     * Variables *
     *************/

    mapping(bytes32 => bool) public relayedMessages;
    mapping(bytes32 => bool) public successfulMessages;
    mapping(bytes32 => bool) public sentMessages;
    uint256 public messageNonce;
    address internal xDomainMsgSender = Lib_DefaultValues.DEFAULT_XDOMAIN_SENDER;
    address public l1CrossDomainMessenger;

    /***************
     * Constructor *
     ***************/

    constructor(address _l1CrossDomainMessenger) {
        l1CrossDomainMessenger = _l1CrossDomainMessenger;
    }

    /********************
     * Public Functions *
     ********************/

    // slither-disable-next-line external-function
    function xDomainMessageSender() public view returns (address) {
        require(
            xDomainMsgSender != Lib_DefaultValues.DEFAULT_XDOMAIN_SENDER,
            "xDomainMessageSender is not set"
        );
        return xDomainMsgSender;
    }

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    // slither-disable-next-line external-function
    function sendMessage(
        address _target,
        bytes memory _message,
        uint32 _gasLimit
    ) public {
        bytes memory xDomainCalldata = Lib_CrossDomainUtils.encodeXDomainCalldata(
            _target,
            msg.sender,
            _message,
            messageNonce
        );

        sentMessages[keccak256(xDomainCalldata)] = true;

        // Actually send the message.
        // slither-disable-next-line reentrancy-no-eth, reentrancy-events
        iOVM_L2ToL1MessagePasser(Lib_PredeployAddresses.L2_TO_L1_MESSAGE_PASSER).passMessageToL1(
            xDomainCalldata
        );

        // Emit an event before we bump the nonce or the nonce will be off by one.
        // slither-disable-next-line reentrancy-events
        emit SentMessage(_target, msg.sender, _message, messageNonce, _gasLimit);
        // slither-disable-next-line reentrancy-no-eth
        messageNonce += 1;
    }

    /**
     * Relays a cross domain message to a contract.
     * @inheritdoc IL2CrossDomainMessenger
     */
    // slither-disable-next-line external-function
    function relayMessage(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce
    ) public {
        // Since it is impossible to deploy a contract to an address on L2 which matches
        // the alias of the L1CrossDomainMessenger, this check can only pass when it is called in
        // the first call from of a deposit transaction. Thus reentrancy is prevented here.
        require(
            AddressAliasHelper.undoL1ToL2Alias(msg.sender) == l1CrossDomainMessenger,
            "Provided message could not be verified."
        );

        bytes memory xDomainCalldata = Lib_CrossDomainUtils.encodeXDomainCalldata(
            _target,
            _sender,
            _message,
            _messageNonce
        );

        bytes32 xDomainCalldataHash = keccak256(xDomainCalldata);

        require(
            successfulMessages[xDomainCalldataHash] == false,
            "Provided message has already been received."
        );

        // Prevent calls to OVM_L2ToL1MessagePasser, which would enable
        // an attacker to maliciously craft the _message to spoof
        // a call from any L2 account.
        if (_target == Lib_PredeployAddresses.L2_TO_L1_MESSAGE_PASSER) {
            // Write to the successfulMessages mapping and return immediately.
            successfulMessages[xDomainCalldataHash] = true;
            return;
        }

        xDomainMsgSender = _sender;
        // slither-disable-next-line reentrancy-no-eth, reentrancy-events, reentrancy-benign
        (bool success, ) = _target.call(_message);
        // slither-disable-next-line reentrancy-benign
        xDomainMsgSender = Lib_DefaultValues.DEFAULT_XDOMAIN_SENDER;

        // Mark the message as received if the call was successful. Ensures that a message can be
        // relayed multiple times in the case that the call reverted.
        if (success == true) {
            // slither-disable-next-line reentrancy-no-eth
            successfulMessages[xDomainCalldataHash] = true;
            // slither-disable-next-line reentrancy-events
            emit RelayedMessage(xDomainCalldataHash);
        } else {
            // slither-disable-next-line reentrancy-events
            emit FailedRelayedMessage(xDomainCalldataHash);
        }

        // Store an identifier that can be used to prove that the given message was relayed by some
        // user. Gives us an easy way to pay relayers for their work.
        bytes32 relayId = keccak256(abi.encodePacked(xDomainCalldata, msg.sender, block.number));

        // slither-disable-next-line reentrancy-benign
        relayedMessages[relayId] = true;
    }
}
