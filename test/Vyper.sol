// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Vm} from "@forge-std/Vm.sol";

library Vyper {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Compiles a Vyper contract and returns the address that the contract was deployed to.
    function deploy(string memory fileName) internal returns (address) {
        return _deploy(_compile(fileName));
    }

    /// @notice Compiles a Vyper contract with constructor arguments and returns the address that the contract was deployed to.
    function deploy(string memory fileName, bytes calldata args) internal returns (address) {
        return _deploy(abi.encodePacked(_compile(fileName), args));
    }

    function _compile(string memory fileName) private returns (bytes memory creationCode) {
        string[] memory cmd = new string[](2);
        cmd[0] = "vyper";
        cmd[1] = string.concat("src/", fileName, ".vy");

        return vm.ffi(cmd);
    }

    function _deploy(bytes memory bytecode) private returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployed != address(0), "Vyper: could not deploy contract");
    }
}
