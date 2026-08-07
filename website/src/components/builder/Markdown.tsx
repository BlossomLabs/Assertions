import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";

/** Compact markdown styling for chat messages, done with descendant
 *  selectors so fenced code inside <pre> sheds the inline-code chrome. */
const mdCls = [
  "text-sm leading-relaxed min-w-0 break-words",
  "[&>*+*]:mt-2",
  "[&_ul]:list-disc [&_ul]:pl-5 [&_ol]:list-decimal [&_ol]:pl-5 [&_li+li]:mt-1",
  "[&_h1]:text-base [&_h1]:font-semibold [&_h2]:text-base [&_h2]:font-semibold",
  "[&_h3]:text-sm [&_h3]:font-semibold [&_h4]:text-sm [&_h4]:font-semibold",
  "[&_strong]:font-semibold",
  "[&_blockquote]:border-l-2 [&_blockquote]:border-[var(--color-ink-3)]/30 [&_blockquote]:pl-3 [&_blockquote]:text-[var(--color-ink-2)]",
  "[&_code]:font-mono [&_code]:text-xs [&_code]:px-1 [&_code]:py-0.5 [&_code]:rounded [&_code]:bg-[var(--color-surface)] [&_code]:border [&_code]:border-[var(--color-ink-3)]/20",
  "[&_pre]:p-3 [&_pre]:rounded-lg [&_pre]:bg-[var(--color-surface)] [&_pre]:border [&_pre]:border-[var(--color-ink-3)]/20 [&_pre]:overflow-x-auto [&_pre]:font-mono [&_pre]:text-xs",
  "[&_pre_code]:bg-transparent [&_pre_code]:border-0 [&_pre_code]:p-0",
  "[&_table]:w-full [&_table]:text-xs",
  "[&_th]:text-left [&_th]:font-semibold [&_th]:px-2 [&_th]:py-1 [&_th]:border-b [&_th]:border-[var(--color-ink-3)]/30",
  "[&_td]:px-2 [&_td]:py-1 [&_td]:border-b [&_td]:border-[var(--color-ink-3)]/15",
  "[&_hr]:border-[var(--color-ink-3)]/20",
].join(" ");

/** Markdown renderer for assistant chat messages. No raw HTML is rendered
 *  (react-markdown's default), so model output stays inert. */
export function Markdown({
  text,
  className = "",
}: {
  text: string;
  className?: string;
}) {
  return (
    <div className={`${mdCls} ${className}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          a: ({ node: _node, ...props }) => (
            <a
              {...props}
              target="_blank"
              rel="noopener noreferrer"
              className="text-[var(--color-bp-300)] hover:underline"
            />
          ),
        }}
      >
        {text}
      </ReactMarkdown>
    </div>
  );
}
