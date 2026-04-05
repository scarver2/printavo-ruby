# examples/diagramming/workflow_diagram.rb
# frozen_string_literal: true

# Printavo Workflow Diagram Example
# ==================================
# Fetches your shop's Printavo statuses and renders the workflow as:
#
#   :mermaid  — GitHub-renderable flowchart (default, no dependencies)
#   :dot      — Graphviz DOT source (pipe to `dot -Tsvg` for SVG/PNG)
#   :ascii    — Terminal-friendly linear chain
#   :svg      — SVG file via dot CLI or ruby-graphviz gem (both optional)
#
# Why examples instead of gem internals?
# ----------------------------------------
# Generating diagrams would require shipping graphviz as a dependency or
# assuming a system `dot` binary — both are burdensome for a Ruby API client.
# This standalone script gives you full control over output and dependencies
# without bloating the gem.
#
# Setup:
#   gem install printavo-ruby dotenv
#   cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
#   ruby workflow_diagram.rb
#
# Optional SVG output (either works independently):
#   brew install graphviz         # for dot CLI approach
#   gem install ruby-graphviz     # for ruby-graphviz gem approach

require 'dotenv/load'
require 'printavo'

client = Printavo::Client.new(
  email: ENV.fetch('PRINTAVO_EMAIL'),
  token: ENV.fetch('PRINTAVO_TOKEN')
)

statuses = client.statuses.all
abort 'No statuses found. Check your credentials.' if statuses.empty?

puts "Fetched #{statuses.size} statuses from Printavo.\n\n"

# ── Helpers ───────────────────────────────────────────────────────────────────

# Safe alphanumeric node identifier — prefixed with 's' to avoid
# starting with a digit (invalid in both Mermaid and DOT).
def node_id(status)
  slug = status.name.downcase.gsub(/[^a-z0-9]+/, '_').squeeze('_').gsub(/^_|_$/, '')
  "s_#{slug}"
end

# Determine readable text color (black or white) against a hex background.
def contrast_color(hex)
  hex = hex.to_s.delete('#').then { |h| h.length == 3 ? h.chars.map { |c| c * 2 }.join : h }
  r, g, b = hex.scan(/../).map { |h| h.to_i(16) }
  ((r * 299) + (g * 587) + (b * 114)) / 1000 > 128 ? '#000000' : '#ffffff'
end

def fill_color(status)
  status.color.to_s.match?(/\A#?[0-9a-fA-F]{3,6}\z/) ? "##{status.color.delete('#')}" : '#888888'
end

# ── Mermaid ───────────────────────────────────────────────────────────────────
#
# Renders as a flowchart in any GitHub Markdown file, issue, PR, wiki page,
# VS Code preview (with Markdown Preview Mermaid Support extension), or
# any tool that supports Mermaid.js.
#
# Paste the output between ```mermaid and ``` fences.

def to_mermaid(statuses)
  lines = ['flowchart LR']
  lines << ''

  statuses.each do |s|
    fill  = fill_color(s)
    color = contrast_color(fill)
    lines << "  #{node_id(s)}[\"#{s.name}\"]"
    lines << "  style #{node_id(s)} fill:#{fill},color:#{color},stroke:#{fill}"
  end

  lines << ''

  statuses.each_cons(2) do |a, b|
    lines << "  #{node_id(a)} --> #{node_id(b)}"
  end

  lines.join("\n")
end

# ── DOT (Graphviz) ────────────────────────────────────────────────────────────
#
# Graphviz DOT source. Pipe it to the dot CLI to generate any format:
#
#   ruby workflow_diagram.rb 2>/dev/null | sed -n '/^digraph/,/^}/p' | dot -Tsvg > workflow.svg
#   ruby workflow_diagram.rb 2>/dev/null | sed -n '/^digraph/,/^}/p' | dot -Tpng > workflow.png
#   ruby workflow_diagram.rb 2>/dev/null | sed -n '/^digraph/,/^}/p' | dot -Tpdf > workflow.pdf
#
# Or use the file written by this script: `dot -Tsvg workflow.dot > workflow.svg`

def dot_node_defs(statuses)
  statuses.map do |s|
    fill = fill_color(s)
    "  #{node_id(s)} [label=\"#{s.name}\", fillcolor=\"#{fill}\", fontcolor=\"#{contrast_color(fill)}\"];"
  end
end

def to_dot(statuses)
  edges = statuses.each_cons(2).map { |a, b| "  #{node_id(a)} -> #{node_id(b)};" }
  [
    'digraph PrintavoWorkflow {',
    '  rankdir=LR;',
    '  graph [fontname="Helvetica", bgcolor=transparent];',
    '  node  [shape=box, style="filled,rounded", fontname="Helvetica", margin="0.2,0.1"];',
    '  edge  [color="#666666", arrowsize=0.8];',
    '', *dot_node_defs(statuses),
    '', *edges,
    '}'
  ].join("\n")
end

# ── ASCII ─────────────────────────────────────────────────────────────────────
#
# Zero-dependency terminal output. Useful for CLI tools, log output,
# or anywhere you want a quick sanity-check of the status order.

def to_ascii(statuses)
  statuses.map(&:name).join(' → ')
end

# ── SVG via dot CLI ───────────────────────────────────────────────────────────
#
# Requires: brew install graphviz  (provides the `dot` binary)
# No gem dependency — shells out to the system dot command.

def svg_via_dot_cli(dot_source)
  require 'open3'
  stdout, stderr, status = Open3.capture3('dot', '-Tsvg', stdin_data: dot_source)
  raise "dot command failed: #{stderr.strip}" unless status.success?

  stdout
end

# ── SVG via ruby-graphviz gem ─────────────────────────────────────────────────
#
# Requires: gem install ruby-graphviz   AND   brew install graphviz
# Gives you a Ruby object model for the graph if you want to manipulate it
# further before rendering.

def configure_graphviz(gviz)
  gviz[:rankdir]        = 'LR'
  gviz.graph[:fontname] = 'Helvetica'
  gviz.graph[:bgcolor]  = 'transparent'
  gviz.node[:shape]     = 'box'
  gviz.node[:style]     = 'filled,rounded'
  gviz.node[:fontname]  = 'Helvetica'
end

def svg_via_graphviz_gem(statuses)
  require 'graphviz'
  g = GraphViz.new(:PrintavoWorkflow, type: :digraph)
  configure_graphviz(g)
  nodes = statuses.map do |s|
    fill = fill_color(s)
    g.add_nodes(node_id(s), label: s.name, fillcolor: fill, fontcolor: contrast_color(fill))
  end
  nodes.each_cons(2) { |a, b| g.add_edges(a, b) }
  g.output(svg: String)
end

# ── Output ────────────────────────────────────────────────────────────────────

separator = '─' * 62

# — ASCII —
puts separator
puts 'ASCII  (linear status chain)'
puts separator
puts to_ascii(statuses)
puts

# — Mermaid —
puts separator
puts 'MERMAID  (paste between ```mermaid fences in any .md file)'
puts separator
puts '```mermaid'
puts to_mermaid(statuses)
puts '```'
puts

# — DOT —
dot_source = to_dot(statuses)
File.write('workflow.dot', dot_source)

puts separator
puts 'GRAPHVIZ DOT  (written to workflow.dot)'
puts separator
puts dot_source
puts

# — SVG via dot CLI —
puts separator
puts 'SVG via dot CLI  (workflow_cli.svg)'
puts separator
begin
  svg = svg_via_dot_cli(dot_source)
  File.write('workflow_cli.svg', svg)
  puts "workflow_cli.svg written — #{svg.bytesize} bytes"
rescue Errno::ENOENT
  puts 'Skipped: `dot` not found — run: brew install graphviz'
rescue RuntimeError => e
  puts "Skipped: #{e.message}"
end
puts

# — SVG via ruby-graphviz gem —
puts separator
puts 'SVG via ruby-graphviz gem  (workflow_gv.svg)'
puts separator
begin
  svg = svg_via_graphviz_gem(statuses)
  File.write('workflow_gv.svg', svg)
  puts "workflow_gv.svg written — #{svg.bytesize} bytes"
rescue LoadError
  puts 'Skipped: run `gem install ruby-graphviz` to enable'
rescue RuntimeError => e
  puts "Skipped: #{e.message}"
end
