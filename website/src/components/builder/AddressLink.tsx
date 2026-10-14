import type { SentenceLink } from "./suggested-checks";
import { noBreakCls } from "./ui";

/**
 * An account, a contract or a token in running text: its label (a name,
 * a shortened address) in one unbreakable piece, linked to its page on
 * the chain's block explorer when there is one, with the full address on
 * hover either way. A name is the contract's own word: the address is
 * what it stands for.
 */
/** What a hover says of where a looked-up name comes from. */
const NAMED_BY = {
  ens: "ENS primary name, resolving back to this address",
  verified: "contract name published with its verified source",
} as const;

/** A looked-up name and the shortened address beside it may wrap apart on
 *  a narrow row; each stays whole, and a name longer than the row breaks
 *  anywhere rather than run under the button beside it. */
function Label({ link }: { link: SentenceLink }) {
  const at = link.named ? link.label.lastIndexOf(" (") : -1;
  if (at < 0) return <>{link.label}</>;
  return (
    <>
      <span className="[overflow-wrap:anywhere]">{link.label.slice(0, at)}</span>{" "}
      <span className={noBreakCls}>{link.label.slice(at + 1)}</span>
    </>
  );
}

export function AddressLink({ link }: { link: SentenceLink }) {
  const title = link.named
    ? `${link.address}\n${NAMED_BY[link.named]}`
    : link.address;
  // A named link wraps between its name and its address; any other is one
  // unbreakable piece.
  const wrapCls = link.named ? "" : noBreakCls;
  return link.href ? (
    <a
      href={link.href}
      title={title}
      target="_blank"
      rel="noreferrer noopener"
      // Underlined in the text's own colour: the builder's link blue is
      // too faint on the light theme's rows.
      className={`${wrapCls} underline underline-offset-2 hover:text-[var(--color-bp-300)]`}
    >
      <Label link={link} />
    </a>
  ) : (
    <span title={title} className={wrapCls}>
      <Label link={link} />
    </span>
  );
}
