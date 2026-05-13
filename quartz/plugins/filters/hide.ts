import { QuartzFilterPlugin } from "../types"

// Прячет заметку с сайта, если в frontmatter есть поле `Скрыть: true`
// (или `скрыть` / `hidden`). В отличие от draft, это НЕ черновик —
// заметка готова, просто не публикуется. В Obsidian остаётся видимой.
export const HideFromSite: QuartzFilterPlugin<{}> = () => ({
  name: "HideFromSite",
  shouldPublish(_ctx, [_tree, vfile]) {
    const fm: any = vfile.data?.frontmatter ?? {}
    const isTrue = (v: any) => v === true || v === "true"
    const hidden = isTrue(fm["Скрыть"]) || isTrue(fm["скрыть"]) || isTrue(fm["hidden"])
    return !hidden
  },
})
