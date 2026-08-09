// NOTE: Do NOT use this module for canonical deployments. Ignition's create2
// strategy deploys through the CreateX factory, which re-hashes the salt and
// therefore produces different addresses than the Arachnid proxy used for the
// canonical Assertions/Operators addresses. Use the website's Deployments
// page (or a manual Arachnid-proxy transaction) instead; this module exists
// only for local testing.
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AssertionsModule", (m) => {
  const assertions = m.contract("Assertions");
  const operators = m.contract("Operators");

  return { assertions, operators };
});
