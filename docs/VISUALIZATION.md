<!-- docs/VISUALIZATION.md -->
# Visualization for [printavo-ruby](https://github.com/scarver2/printavo-ruby)

## Workflow Diagram Generation

See **[examples/diagramming/workflow_diagram.rb](../examples/diagramming/workflow_diagram.rb)**
for a complete, runnable example covering all four output formats.

Adding diagram generation to the gem itself would require either shipping
`ruby-graphviz` as a hard dependency or assuming a system `dot` binary —
both are burdensome for a Ruby API client. The standalone example gives
consumers full control over their output format and toolchain without
bloating the gem.

**Supported formats in the example:**

| Format | Dependency | Best for |
|---|---|---|
| `:ascii` | none | Terminal output, quick sanity-check |
| `:mermaid` | none | GitHub README/issues/PRs, VS Code preview |
| `:dot` | none (text) | Piping to `dot -Tsvg` or any Graphviz renderer |
| `:svg` | `brew install graphviz` or `gem install ruby-graphviz` | Production-grade visual files |

Statuses are fetched via `client.statuses.all` and rendered as a linear
left-to-right flow in the order Printavo returns them. Printavo has no
explicit transition edges in its API — the workflow is an implied sequence.

### Quick Start

```bash
cd examples/diagramming
cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
gem install printavo-ruby dotenv
ruby workflow_diagram.rb
```

Output files written to the current directory:

| File | Format |
|---|---|
| *(stdout)* | ASCII chain |
| *(stdout)* | Mermaid fenced block |
| `workflow.dot` | Graphviz DOT source |
| `workflow_cli.svg` | SVG via `dot` CLI (if graphviz installed) |
| `workflow_gv.svg` | SVG via `ruby-graphviz` gem (if installed) |

### Rendering DOT to Other Formats

```bash
# SVG
dot -Tsvg workflow.dot > workflow.svg

# PNG
dot -Tpng workflow.dot > workflow.png

# PDF
dot -Tpdf workflow.dot > workflow.pdf
```

### Embedding Mermaid in GitHub Markdown

Paste the Mermaid output between fences in any `.md` file:

````markdown
```mermaid
flowchart LR
  s_quote["Quote"] --> s_in_production["In Production"] --> s_completed["Completed"]
```
````

GitHub renders it automatically in READMEs, issues, PRs, and wiki pages.

---

## Colophon

[MIT License](LICENSE)

&copy;2026 [Stan Carver II](https://stancarver.com)

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
