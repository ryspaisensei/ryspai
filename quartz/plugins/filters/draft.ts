import { QuartzFilterPlugin } from "../types"

export const RemoveDrafts: QuartzFilterPlugin<{}> = () => ({
  name: "RemoveDrafts",
  shouldPublish(_ctx, [_tree, vfile]) {
    const fm: any = vfile.data?.frontmatter ?? {}
    const isTrue = (v: any) => v === true || v === "true"
    const draftFlag: boolean = isTrue(fm.draft) || isTrue(fm["Скрыть"]) || isTrue(fm["скрыть"])
    return !draftFlag
  },
})
