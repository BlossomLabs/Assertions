import type { SentenceLink } from "./suggested-checks";
import { noBreakCls } from "./ui";

/**
 * An account, a contract or a token in running text: its label (a name,
 * a shortened address) in one unbreakable piece, linked to its page on
 * the chain's block explorer when there is one, with the full address on
 * hover either way. A name is the contract's own word: the address is
 * what it stands for.
 */
export function AddressLink({ link }: { link: SentenceLink }) {
  return link.href ? (
    <a
      href={link.href}
      title={link.address}
      target="_blank"
      rel="noreferrer noopener"
      // Underlined in the text's own colour: the builder's link blue is
      // too faint on the light theme's rows.
      className={`${noBreakCls} underline underline-offset-2 hover:text-[var(--color-bp-300)]`}
    >
      {link.label}
    </a>
  ) : (
    <span title={link.address} className={noBreakCls}>
      {link.label}
    </span>
  );
}
