import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useRef, useState } from "react";
import type { Chain } from "viem";
import { mainnet } from "viem/chains";
import { WagmiProvider } from "wagmi";

import { DeploySection } from "./DeploySection";
import { DeploymentsTable } from "./DeploymentsTable";
import { wagmiConfig } from "./wagmi";

const queryClient = new QueryClient();

function Deployments() {
  const [chain, setChain] = useState<Chain>(mainnet);
  const deployRef = useRef<HTMLDivElement>(null);

  return (
    <div className="space-y-10">
      <DeploymentsTable
        onDeploy={(target) => {
          setChain(target);
          deployRef.current?.scrollIntoView({
            behavior: "smooth",
            block: "start",
          });
        }}
      />
      <div ref={deployRef} className="scroll-mt-24">
        <DeploySection chain={chain} onChainChange={setChain} />
      </div>
    </div>
  );
}

export default function DeploymentsApp() {
  // Providers live inside the island (Astro pages have no React root above).
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <Deployments />
      </QueryClientProvider>
    </WagmiProvider>
  );
}
