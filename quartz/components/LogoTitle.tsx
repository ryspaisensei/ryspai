import { pathToRoot } from "../util/path"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"
import { i18n } from "../i18n"

const LogoTitle: QuartzComponent = ({ fileData, cfg, displayClass }: QuartzComponentProps) => {
  const title = cfg?.pageTitle ?? i18n(cfg.locale).propertyDefaults.title
  const baseDir = pathToRoot(fileData.slug!)
  const logoSrc = baseDir + "/assets/asset_logo.jpg"
  return (
    <div class={classNames(displayClass, "logo-title")}>
      <a href={baseDir} class="logo-title-link" aria-label={title}>
        <img src={logoSrc} alt={title} class="logo-title-img" />
      </a>
    </div>
  )
}

LogoTitle.css = `
.logo-title {
  margin: 0 0 1rem 0;
}
.logo-title-link {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-decoration: none;
  color: inherit;
  gap: 0.5rem;
}
.logo-title-link:hover {
  text-decoration: none;
}
.logo-title-img {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--lightgray);
  transition: border-color 0.2s ease;
}
.logo-title-link:hover .logo-title-img {
  border-color: var(--secondary);
}
.logo-title-name {
  font-size: 1.4rem;
  margin: 0;
  font-family: var(--titleFont);
  text-align: center;
  color: var(--dark);
}
`

export default (() => LogoTitle) satisfies QuartzComponentConstructor
