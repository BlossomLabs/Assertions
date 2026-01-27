import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AssertionsModule", (m) => {
  const assertions = m.contract("Assertions");

  return { assertions };
});
