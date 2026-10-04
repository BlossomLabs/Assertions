import type { ReactNode } from "react";

import arbitrum from "../../assets/chains/arbitrum.svg?url";
import base from "../../assets/chains/base.svg?url";
import gnosis from "../../assets/chains/gnosis.svg?url";
import optimism from "../../assets/chains/optimism.png?url";
import polygon from "../../assets/chains/polygon.svg?url";

/**
 * The mark shown beside a network name. Chains with a bundled logo render
 * it; every other chain gets a neutral disc carrying its initial, tinted
 * from the chain id so neighbours in a list stay distinguishable.
 *
 * Always decorative: the network name sits next to it.
 */

const ethereum = (disc: string) => (
  <>
    <circle cx="16" cy="16" r="16" fill={disc} />
    <g fill="#fff">
      <path fillOpacity=".6" d="M16.498 4v8.87l7.497 3.35z" />
      <path d="M16.498 4 9 16.22l7.498-3.35z" />
      <path fillOpacity=".6" d="M16.498 21.968v6.027L24 17.616z" />
      <path d="M16.498 27.995v-6.028L9 17.616z" />
      <path fillOpacity=".2" d="m16.498 20.573 7.497-4.353-7.497-3.348z" />
      <path fillOpacity=".6" d="m9 16.22 7.498 4.353v-7.701z" />
    </g>
  </>
);

/** Logos drawn inline by chain id, each on a 32x32 canvas. */
const MARKS: Record<number, ReactNode> = {
  1: ethereum("#627EEA"),
  11155111: ethereum("#8A92B2"),
};

/** Logo files by chain id, from each project's own published assets. */
const IMAGES: Record<number, string> = {
  10: optimism,
  100: gnosis,
  137: polygon,
  8453: base,
  42161: arbitrum,
};

export interface ChainIconProps {
  chainId: number;
  /** Supplies the initial for chains without a bundled logo. */
  name?: string;
  /** Rendered width and height in pixels. */
  size?: number;
  className?: string;
}

export function ChainIcon({
  chainId,
  name,
  size = 16,
  className = "",
}: ChainIconProps) {
  const image = IMAGES[chainId];
  if (image) {
    return (
      <img
        className={`shrink-0 ${className}`}
        src={image}
        width={size}
        height={size}
        alt=""
        aria-hidden="true"
      />
    );
  }
  const mark = MARKS[chainId];
  return (
    <svg
      className={`shrink-0 ${className}`}
      width={size}
      height={size}
      viewBox="0 0 32 32"
      aria-hidden="true"
      focusable="false"
    >
      {mark ?? (
        <>
          <circle
            cx="16"
            cy="16"
            r="16"
            fill={`hsl(${(chainId * 137.508) % 360} 42% 46%)`}
          />
          <text
            x="16"
            y="16"
            dy=".35em"
            textAnchor="middle"
            fontFamily="ui-sans-serif, system-ui, sans-serif"
            fontSize="17"
            fontWeight="600"
            fill="#fff"
          >
            {(name?.trim()[0] ?? "#").toUpperCase()}
          </text>
        </>
      )}
    </svg>
  );
}

export default ChainIcon;
