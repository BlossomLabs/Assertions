// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../contracts/Assertions.sol";
import "../../contracts/lib/ERC8211.sol";

/**
 * @notice Establishes how a Safe executing a MultiSend batch treats a failing
 *         Assertions call, on a Gnosis-chain fork against Safe's canonical
 *         deployments (v1.3.0 and v1.4.1). Skipped when GNOSIS_RPC_URL is unset.
 */

interface ISafeProxyFactory {
    function createProxyWithNonce(address singleton, bytes memory initializer, uint256 saltNonce)
        external
        returns (address proxy);
}

interface ISafe {
    function setup(
        address[] calldata owners,
        uint256 threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    function nonce() external view returns (uint256);

    function VERSION() external view returns (string memory);

    function approveHash(bytes32 hashToApprove) external;

    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);
}

contract SafeCounterTarget {
    uint256 public counter;

    function set(uint256 value) external {
        counter = value;
    }
}

abstract contract SafeMultiSendBase is Test {
    // The asserted word is 5. FAIL requires >= 10, PASS requires >= 3; the
    // two variants differ only in this reference word.
    bytes4 internal constant ASSERT_PARAM = bytes4(keccak256("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))"));
    uint256 internal constant ACTUAL = 5;
    uint256 internal constant FAIL_REF = 10;
    uint256 internal constant PASS_REF = 3;
    uint256 internal constant CHAIN_ID = 100;

    // Safe emits one of these from execTransaction. Same topic0 in v1.3.0 and
    // v1.4.1 (the indexing of txHash differs), so match on topic0 only.
    bytes32 internal constant EXECUTION_FAILURE = keccak256("ExecutionFailure(bytes32,uint256)");
    bytes32 internal constant EXECUTION_SUCCESS = keccak256("ExecutionSuccess(bytes32,uint256)");

    // Deployment under test.
    function versionLabel() internal pure virtual returns (string memory);
    function factoryAddr() internal pure virtual returns (address);
    function singletonAddr() internal pure virtual returns (address);
    function multiSendCallOnlyAddr() internal pure virtual returns (address);
    function multiSendAddr() internal pure virtual returns (address);

    Assertions internal assertions;
    SafeCounterTarget internal target;
    ISafe internal safe;
    uint256 internal ownerKey = 0xA11CE;
    address internal owner;

    function setUp() public {
        string memory url = vm.envOr("GNOSIS_RPC_URL", string(""));
        if (bytes(url).length == 0) {
            vm.skip(true, "GNOSIS_RPC_URL is not set: Safe fork tests skipped");
            return;
        }
        vm.createSelectFork(url);
        assertEq(block.chainid, CHAIN_ID, "GNOSIS_RPC_URL must point at Gnosis chain");

        // Every address used must be live code answering its known getter.
        assertGt(factoryAddr().code.length, 0, "factory has code");
        assertGt(singletonAddr().code.length, 0, "singleton has code");
        assertGt(multiSendCallOnlyAddr().code.length, 0, "MultiSendCallOnly has code");
        assertGt(multiSendAddr().code.length, 0, "MultiSend has code");
        assertEq(ISafe(singletonAddr()).VERSION(), versionLabel(), "singleton VERSION()");

        owner = vm.addr(ownerKey);
        address[] memory owners = new address[](1);
        owners[0] = owner;
        bytes memory init =
            abi.encodeCall(ISafe.setup, (owners, 1, address(0), "", address(0), address(0), 0, payable(address(0))));
        safe = ISafe(ISafeProxyFactory(factoryAddr()).createProxyWithNonce(singletonAddr(), init, 1));
        assertEq(safe.VERSION(), versionLabel(), "proxy VERSION()");

        assertions = new Assertions();
        target = new SafeCounterTarget();
    }

    // ============ Helpers ============

    function _assertParamCall(uint256 threshold) internal view returns (bytes memory) {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.GTE, abi.encode(threshold));
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(ACTUAL), cs);
        return abi.encodeWithSelector(ASSERT_PARAM, p);
    }

    function _packed(address to, bytes memory data) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(0), to, uint256(0), data.length, data);
    }

    /// Calls the batch [set(1), assertParam] (or reversed) through MultiSend.
    function _batch(bool assertionFirst, uint256 threshold) internal view returns (bytes memory) {
        bytes memory set = _packed(address(target), abi.encodeCall(target.set, (1)));
        bytes memory check = _packed(address(assertions), _assertParamCall(threshold));
        bytes memory txs = assertionFirst ? bytes.concat(check, set) : bytes.concat(set, check);
        return abi.encodeWithSignature("multiSend(bytes)", txs);
    }

    function _exec(address multiSend, bytes memory data, uint256 safeTxGas)
        internal
        returns (bool ok, bytes memory ret)
    {
        uint256 n = safe.nonce();
        bytes32 h = safe.getTransactionHash(multiSend, 0, data, 1, safeTxGas, 0, 0, address(0), address(0), n);
        // Pre-validated signature: r = owner, s = 0, v = 1 (owner must be msg.sender).
        bytes memory sig = abi.encodePacked(bytes32(uint256(uint160(owner))), bytes32(0), uint8(1));
        vm.startPrank(owner);
        safe.approveHash(h);
        (ok, ret) = address(safe)
            .call(
                abi.encodeCall(
                    ISafe.execTransaction, (multiSend, 0, data, 1, safeTxGas, 0, 0, address(0), address(0), sig)
                )
            );
        vm.stopPrank();
    }

    function _expectGS013(bool ok, bytes memory ret) internal pure {
        assertFalse(ok, "execTransaction reverts");
        assertEq(ret, abi.encodeWithSignature("Error(string)", "GS013"), "Safe's inner-failure revert");
    }

    function _safeEmitted(Vm.Log[] memory logs, bytes32 topic0) internal view returns (bool found) {
        for (uint256 i; i < logs.length; ++i) {
            if (logs[i].emitter == address(safe) && logs[i].topics[0] == topic0) found = true;
        }
    }

    function _targets() internal view returns (address[2] memory t) {
        t[0] = multiSendCallOnlyAddr();
        t[1] = multiSendAddr();
    }

    // ============ safeTxGas = 0 ============

    function test_failingAssertion_safeTxGasZero_revertsAndKeepsCounterZero() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            uint256 nonceBefore = safe.nonce();
            (bool ok, bytes memory ret) = _exec(ms[i], _batch(false, FAIL_REF), 0);
            _expectGS013(ok, ret);
            assertEq(target.counter(), 0, "earlier call rolled back");
            assertEq(safe.nonce(), nonceBefore, "nonce not consumed");
        }
    }

    function test_failingAssertionFirst_safeTxGasZero_revertsAndKeepsCounterZero() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            (bool ok, bytes memory ret) = _exec(ms[i], _batch(true, FAIL_REF), 0);
            _expectGS013(ok, ret);
            assertEq(target.counter(), 0);
        }
    }

    function test_passingAssertion_safeTxGasZero_executes() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            target.set(0);
            uint256 nonceBefore = safe.nonce();
            (bool ok, bytes memory ret) = _exec(ms[i], _batch(false, PASS_REF), 0);
            assertTrue(ok, "execTransaction succeeds");
            assertTrue(abi.decode(ret, (bool)), "inner batch succeeded");
            assertEq(target.counter(), 1);
            assertEq(safe.nonce(), nonceBefore + 1);
        }
    }

    function test_passingAssertionFirst_safeTxGasZero_executes() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            target.set(0);
            (bool ok, bytes memory ret) = _exec(ms[i], _batch(true, PASS_REF), 0);
            assertTrue(ok);
            assertTrue(abi.decode(ret, (bool)));
            assertEq(target.counter(), 1);
        }
    }

    // ============ safeTxGas > 0 ============

    // With a nonzero safeTxGas the Safe tolerates inner failure: it returns
    // false and consumes the nonce, but MultiSend's revert has already undone
    // the earlier call.
    function test_failingAssertion_safeTxGasNonzero_returnsFalseAndKeepsCounterZero() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            uint256 nonceBefore = safe.nonce();
            bytes memory data = _batch(false, FAIL_REF);

            vm.recordLogs();
            (bool ok, bytes memory ret) = _exec(ms[i], data, 3_000_000);
            Vm.Log[] memory logs = vm.getRecordedLogs();
            assertTrue(_safeEmitted(logs, EXECUTION_FAILURE), "ExecutionFailure emitted");
            assertFalse(_safeEmitted(logs, EXECUTION_SUCCESS), "no ExecutionSuccess");

            assertTrue(ok, "execTransaction does not revert");
            assertFalse(abi.decode(ret, (bool)), "returns false");
            assertEq(target.counter(), 0, "earlier call rolled back");
            assertEq(safe.nonce(), nonceBefore + 1, "nonce consumed");
        }
    }

    function test_passingAssertion_safeTxGasNonzero_executes() public {
        address[2] memory ms = _targets();
        for (uint256 i; i < 2; ++i) {
            target.set(0);
            bytes memory data = _batch(false, PASS_REF);

            vm.recordLogs();
            (bool ok, bytes memory ret) = _exec(ms[i], data, 3_000_000);
            Vm.Log[] memory logs = vm.getRecordedLogs();
            assertTrue(_safeEmitted(logs, EXECUTION_SUCCESS), "ExecutionSuccess emitted");
            assertFalse(_safeEmitted(logs, EXECUTION_FAILURE), "no ExecutionFailure");

            assertTrue(ok);
            assertTrue(abi.decode(ret, (bool)));
            assertEq(target.counter(), 1);
        }
    }
}

/// Safe v1.3.0 canonical deployments on Gnosis chain.
contract SafeV130MultiSendTest is SafeMultiSendBase {
    function versionLabel() internal pure override returns (string memory) {
        return "1.3.0";
    }

    function factoryAddr() internal pure override returns (address) {
        return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
    }

    function singletonAddr() internal pure override returns (address) {
        return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    }

    function multiSendCallOnlyAddr() internal pure override returns (address) {
        return 0x40A2aCCbd92BCA938b02010E17A5b8929b49130D;
    }

    function multiSendAddr() internal pure override returns (address) {
        return 0xA238CBeb142c10Ef7Ad8442C6D1f9E89e07e7761;
    }
}

/// Safe v1.4.1 canonical deployments on Gnosis chain.
contract SafeV141MultiSendTest is SafeMultiSendBase {
    function versionLabel() internal pure override returns (string memory) {
        return "1.4.1";
    }

    function factoryAddr() internal pure override returns (address) {
        return 0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67;
    }

    function singletonAddr() internal pure override returns (address) {
        return 0x41675C099F32341bf84BFc5382aF534df5C7461a;
    }

    function multiSendCallOnlyAddr() internal pure override returns (address) {
        return 0x9641d764fc13c8B624c04430C7356C1C7C8102e2;
    }

    function multiSendAddr() internal pure override returns (address) {
        return 0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526;
    }
}
