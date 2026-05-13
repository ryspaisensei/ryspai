import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"

const SimpleFooter: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <footer class={`${displayClass ?? ""} simple-footer`}>
      <p>
        Telegram канал «Таков путь»{" "}
        <a href="https://t.me/ryspaisensei/" target="_blank" rel="noopener noreferrer">
          @ryspaisensei
        </a>
      </p>
    </footer>
  )
}

SimpleFooter.css = `
.simple-footer {
  text-align: center;
  padding: 1rem 0;
  color: var(--gray);
  font-size: 0.9rem;
}
.simple-footer a {
  color: var(--secondary);
  text-decoration: none;
}
.simple-footer a:hover {
  text-decoration: underline;
}
`

export default (() => SimpleFooter) satisfies QuartzComponentConstructor
