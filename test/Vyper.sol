// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Vm} from "@forge-std/Vm.sol";

contract Vyper {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Compiles a Vyper contract and returns the address that the contract was deployed to.
    function deploy(string memory fileName) public returns (address) {
        bytes memory bytecode = _compile(fileName);

        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Vyper: could not deploy contract");

        return deployedAddress;
    }

    /// @notice Compiles a Vyper contract with constructor arguments and returns the address that the contract was deployed to.
    function deploy(string memory fileName, bytes calldata args) public returns (address) {
        bytes memory bytecode = abi.encodePacked(_compile(fileName), args);

        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Vyper: could not deploy contract");

        return deployedAddress;
    }

    function _compile(string memory fileName) internal returns (bytes memory creationCode) {
        string[] memory cmd = new string[](2);
        cmd[0] = "vyper";
        cmd[1] = string.concat("src/", fileName, ".vy");

        return vm.ffi(cmd);
    }
}
