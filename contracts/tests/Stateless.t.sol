// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import {Operations} from "../Operations.sol";

/**
 *  @dev Makes a plain CALL: the scan must refuse it
 */
contract Caller {
    function poke(address a) external returns (bool ok) {
        (ok,) = a.call("");
    }
}

/**
 *  @dev Writes storage: the scan must refuse it
 */
contract Writer {
    uint256 x;

    function set(uint256 v) external {
        x = v;
    }
}

/**
 * @notice The four contracts cannot change state, by construction: their
 *         runtime code contains no instruction that writes storage or
 *         transient storage, emits a log, creates or destroys a contract, or
 *         makes any call but STATICCALL
 * @dev A walk over the deployed runtime, opcode by opcode, stepping over
 *      PUSH immediates and stopping before the CBOR metadata trailer (whose
 *      length the last two bytes give). `view` and `pure` are compile-time
 *      claims about the source; this checks the bytes that deploy.
 */
contract StatelessTest is Test {
    function forbidden(uint8 op) internal pure returns (string memory) {
        if (op == 0x55) return "SSTORE";
        if (op == 0x5d) return "TSTORE";
        if (op >= 0xa0 && op <= 0xa4) return "LOG";
        if (op == 0xf0) return "CREATE";
        if (op == 0xf1) return "CALL";
        if (op == 0xf2) return "CALLCODE";
        if (op == 0xf4) return "DELEGATECALL";
        if (op == 0xf5) return "CREATE2";
        if (op == 0xff) return "SELFDESTRUCT";
        return "";
    }

    /**
     * @dev Fails with the first forbidden opcode and its offset, and returns how many STATICCALLs the code holds
     */
    function scan(address account, string memory name) internal view returns (uint256 staticcalls) {
        bytes memory code = account.code;
        uint256 metadata = (uint256(uint8(code[code.length - 2])) << 8) | uint8(code[code.length - 1]);
        uint256 end = code.length - metadata - 2;
        for (uint256 i; i < end; i++) {
            uint8 op = uint8(code[i]);
            if (op >= 0x60 && op <= 0x7f) {
                i += op - 0x5f;
                continue;
            }
            string memory bad = forbidden(op);
            assertEq(bytes(bad).length, 0, string.concat(name, " holds ", bad, " at byte ", vm.toString(i)));
            if (op == 0xfa) staticcalls++;
        }
    }

    function test_noContractCanChangeState() public {
        scan(address(new Assertions()), "Assertions");
        scan(address(new Operations()), "Operations");
        scan(address(new Collections()), "Collections");
        scan(address(new Expressions()), "Expressions");
    }

    /**
     * @dev The scan is not vacuous: it finds the STATICCALLs every external call compiles to
     */
    function test_scanSeesTheStaticcalls() public {
        assertGt(scan(address(new Assertions()), "Assertions"), 0);
        assertGt(scan(address(new Collections()), "Collections"), 0);
    }

    function scanExternal(address account) external view {
        scan(account, "probe");
    }

    /**
     * @dev The scan is not vacuous the other way either: a CALL and an SSTORE each fail it
     */
    function test_scanRefusesStateChanges() public {
        (bool ok,) = address(this).call(abi.encodeCall(this.scanExternal, (address(new Caller()))));
        assertFalse(ok, "the scan missed a CALL");
        (ok,) = address(this).call(abi.encodeCall(this.scanExternal, (address(new Writer()))));
        assertFalse(ok, "the scan missed an SSTORE");
    }
}
