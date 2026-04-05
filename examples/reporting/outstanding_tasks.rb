# examples/reporting/outstanding_tasks.rb
# frozen_string_literal: true

# Printavo Outstanding Tasks Report
# ====================================
# Pages through all tasks, filters to incomplete ones, and renders a
# prioritized report grouped by urgency:
#
#   OVERDUE       — past due date, not yet complete
#   DUE TODAY     — due date is today
#   DUE THIS WEEK — due within the next 7 days
#   UPCOMING      — due more than 7 days from now
#   NO DUE DATE   — no deadline set
#
# Each section is sorted by due date (oldest first for overdue, soonest
# first for upcoming). A summary table by assignee is printed at the end.
#
# An HTML calendar is also written to tasks_calendar.html covering the
# date range of all tasks with due dates. Override the range with:
#
#   CALENDAR_START=2026-04-01 CALENDAR_END=2026-06-30 ruby outstanding_tasks.rb
#
# Setup:
#   gem install printavo-ruby dotenv
#   cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
#   ruby outstanding_tasks.rb

require 'date'
require 'dotenv/load'
require 'printavo'

client = Printavo::Client.new(
  email: ENV.fetch('PRINTAVO_EMAIL'),
  token: ENV.fetch('PRINTAVO_TOKEN'),
  cache: Printavo::MemoryStore.new
)

puts 'Fetching tasks from Printavo...'
all_tasks = client.tasks.all_pages(first: 100)
puts "Fetched #{all_tasks.size} tasks total.\n\n"

# ── Filter ────────────────────────────────────────────────────────────────────

outstanding = all_tasks.reject(&:completed?)
abort "No outstanding tasks. You're all caught up! 🎉" if outstanding.empty?

# ── Date Helpers ──────────────────────────────────────────────────────────────

TODAY     = Date.today
END_WEEK  = TODAY + 7

def parse_date(str)
  Date.parse(str.to_s[0, 10])
rescue Date::Error, TypeError
  nil
end

def days_overdue(task)
  due = parse_date(task.due_at)
  return nil unless due

  (TODAY - due).to_i
end

# ── Bucketing ─────────────────────────────────────────────────────────────────

buckets = { overdue: [], today: [], this_week: [], upcoming: [], no_due_date: [] }

outstanding.each do |task|
  due = parse_date(task.due_at)
  bucket = if due.nil?
             :no_due_date
           elsif due < TODAY
             :overdue
           elsif due == TODAY
             :today
           elsif due <= END_WEEK
             :this_week
           else
             :upcoming
           end
  buckets[bucket] << task
end

# Sort each bucket by due date
buckets[:overdue].sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:today].sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:this_week].sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:upcoming].sort_by! { |t| parse_date(t.due_at) || Date::Infinity.new }
buckets[:no_due_date].sort_by! { |t| t.body.to_s }

# ── Formatting ────────────────────────────────────────────────────────────────

def assignee_name(task)
  a = task.assignee
  return 'Unassigned' if a.nil?

  "#{a['firstName']} #{a['lastName']}".strip.then { |n| n.empty? ? 'Unassigned' : n }
end

def format_due(task)
  due = parse_date(task.due_at)
  return '—' unless due

  days = (due - TODAY).to_i
  label = if days.negative?
            "#{days.abs}d overdue"
          elsif days.zero?
            'today'
          else
            "in #{days}d"
          end
  "#{due.strftime('%b %-d')}  #{label}"
end

def print_task(task, index)
  puts "  #{index.to_s.rjust(3)}. #{task.body.to_s.slice(0, 42).ljust(42)}  " \
       "#{assignee_name(task).ljust(16)}  #{format_due(task)}"
end

def print_section(title, tasks, color_code = nil)
  return if tasks.empty?

  separator = '─' * 72
  prefix = color_code ? "\e[#{color_code}m" : ''
  reset  = color_code ? "\e[0m" : ''
  puts separator
  puts "#{prefix}  #{title}  (#{tasks.size})#{reset}"
  puts separator
  tasks.each_with_index { |task, i| print_task(task, i + 1) }
  puts
end

# ── Summary Header ────────────────────────────────────────────────────────────

puts '═' * 72
puts "  OUTSTANDING TASKS  —  #{TODAY.strftime('%B %-d, %Y')}"
puts '═' * 72
puts "  Total outstanding: #{outstanding.size}  |  Overdue: #{buckets[:overdue].size}  " \
     "|  Due today: #{buckets[:today].size}  " \
     "|  Upcoming: #{buckets[:this_week].size + buckets[:upcoming].size}"
puts

# ── Sections ─────────────────────────────────────────────────────────────────
# ANSI color codes: 31=red, 33=yellow, 36=cyan, 32=green, 0=reset

print_section('OVERDUE',        buckets[:overdue],    '1;31')  # bold red
print_section('DUE TODAY',      buckets[:today],      '1;33')  # bold yellow
print_section('DUE THIS WEEK',  buckets[:this_week],  '36')    # cyan
print_section('UPCOMING',       buckets[:upcoming],   '32')    # green
print_section('NO DUE DATE',    buckets[:no_due_date])

# ── Assignee Summary ──────────────────────────────────────────────────────────

puts '─' * 72
puts '  OUTSTANDING BY ASSIGNEE'
puts '─' * 72

outstanding
  .group_by { |t| assignee_name(t) }
  .sort_by  { |_, tasks| -tasks.size }
  .each do |name, tasks|
    overdue_count = tasks.count { |t| (d = parse_date(t.due_at)) && d < TODAY }
    overdue_str   = overdue_count.positive? ? "  \e[1;31m#{overdue_count} overdue\e[0m" : ''
    puts "  #{name.ljust(30)} #{tasks.size.to_s.rjust(3)} task#{'s' unless tasks.size == 1}#{overdue_str}"
  end
puts

# ── HTML Calendar ─────────────────────────────────────────────────────────────
#
# Builds a self-contained HTML file (no external CDN) showing outstanding tasks
# on a monthly calendar grid. Color coding matches the terminal output above.
#
# Calendar range defaults to the span of all task due dates. Override with:
#   CALENDAR_START=YYYY-MM-DD  CALENDAR_END=YYYY-MM-DD

TASK_COLORS = {
  overdue: { bg: '#ef4444', text: '#fff', label: 'Overdue' },
  today: { bg: '#f59e0b', text: '#fff', label: 'Due Today' },
  this_week: { bg: '#3b82f6', text: '#fff', label: 'This Week' },
  upcoming: { bg: '#22c55e', text: '#fff', label: 'Upcoming' }
}.freeze

def task_bucket_key(task)
  due = parse_date(task.due_at)
  return nil if due.nil?

  if due < TODAY      then :overdue
  elsif due == TODAY  then :today
  elsif due <= END_WEEK then :this_week
  else :upcoming
  end
end

def html_escape(str)
  str.to_s
     .gsub('&', '&amp;')
     .gsub('<', '&lt;')
     .gsub('>', '&gt;')
     .gsub('"', '&quot;')
end

def calendar_months(start_date, end_date)
  months = []
  d = Date.new(start_date.year, start_date.month, 1)
  last = Date.new(end_date.year, end_date.month, 1)
  while d <= last
    months << d
    d >>= 1
  end
  months
end

def month_header_html(month_name)
  day_headers = %w[Mon Tue Wed Thu Fri Sat Sun].map { |d| "<th>#{d}</th>" }.join
  '<table class="month-grid">' \
    "<thead><tr><th colspan=\"7\" class=\"month-name\">#{html_escape(month_name)}</th></tr>" \
    "<tr>#{day_headers}</tr></thead>" \
    '<tbody><tr>'
end

def day_chips_html(day_tasks)
  day_tasks.map do |t|
    colors = TASK_COLORS[task_bucket_key(t)] || { bg: '#6b7280', text: '#fff' }
    tip    = html_escape("#{t.body} — #{assignee_name(t)}")
    "<span class=\"chip\" style=\"background:#{colors[:bg]};color:#{colors[:text]}\" " \
      "title=\"#{tip}\">#{html_escape(t.body.to_s.slice(0, 28))}</span>"
  end.join
end

def day_cell_html(date, tasks_by_date)
  day_tasks  = tasks_by_date[date] || []
  is_today   = date == TODAY
  css        = ['day']
  css << 'today'     if is_today
  css << 'has-tasks' unless day_tasks.empty?
  css << 'past'      if date < TODAY && !is_today
  "<td class=\"#{css.join(' ')}\">" \
    "<div class=\"day-num\">#{date.day}</div>" \
    "<div class=\"chips\">#{day_chips_html(day_tasks)}</div></td>"
end

def render_month(year, month, tasks_by_date) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  first       = Date.new(year, month, 1)
  last        = Date.new(year, month, -1)
  lead_blanks = (first.wday + 6) % 7
  rows        = [month_header_html(first.strftime('%B %Y'))]

  rows << ('<td class="blank"></td>' * lead_blanks)
  cell_count = lead_blanks

  (first..last).each do |date|
    rows << day_cell_html(date, tasks_by_date)
    cell_count += 1
    rows << '</tr><tr>' if (cell_count % 7).zero?
  end

  remainder = cell_count % 7
  if remainder.positive?
    rows << ('<td class="blank"></td>' * (7 - remainder))
    rows << '</tr>'
  end

  rows << '</tbody></table>'
  rows.join("\n")
end

def legend_html
  TASK_COLORS.map do |_, c|
    "<span class=\"legend-chip\" style=\"background:#{c[:bg]};color:#{c[:text]}\">#{c[:label]}</span>"
  end.join(' ')
end

def no_date_section_html(tasks_without)
  return '' if tasks_without.empty?

  rows = tasks_without.map do |t|
    "<tr><td>#{html_escape(t.body)}</td><td>#{html_escape(assignee_name(t))}</td></tr>"
  end.join("\n")

  <<~HTML
    <section class="no-date">
      <h2>No Due Date (#{tasks_without.size})</h2>
      <table class="no-date-table">
        <thead><tr><th>Task</th><th>Assignee</th></tr></thead>
        <tbody>#{rows}</tbody>
      </table>
    </section>
  HTML
end

def month_grids_html(tasks_by_date, cal_start, cal_end)
  calendar_months(cal_start, cal_end)
    .map { |d| render_month(d.year, d.month, tasks_by_date) }
    .each_slice(3)
    .map { |row| "<div class=\"month-row\">#{row.join}</div>" }
    .join("\n")
end

def build_html_calendar(outstanding, cal_start, cal_end) # rubocop:disable Metrics/MethodLength
  tasks_with_dates, tasks_without = outstanding.partition { |t| parse_date(t.due_at) }

  tasks_by_date = Hash.new { |h, k| h[k] = [] }
  tasks_with_dates.each { |t| tasks_by_date[parse_date(t.due_at)] << t }

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Outstanding Tasks — #{TODAY.strftime('%B %-d, %Y')}</title>
      <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
               font-size: 13px; color: #1f2937; background: #f9fafb; padding: 24px; }
        h1   { font-size: 20px; font-weight: 700; margin-bottom: 4px; }
        h2   { font-size: 15px; font-weight: 600; margin: 24px 0 10px; color: #374151; }
        .subtitle { color: #6b7280; margin-bottom: 20px; }
        .legend   { margin-bottom: 24px; display: flex; gap: 8px; flex-wrap: wrap; }
        .legend-chip { padding: 3px 10px; border-radius: 999px; font-size: 12px;
                       font-weight: 500; }
        .month-row  { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 28px; }
        .month-grid { border-collapse: collapse; width: 320px; background: #fff;
                      border-radius: 8px; overflow: hidden;
                      box-shadow: 0 1px 3px rgba(0,0,0,.1); }
        .month-grid th, .month-grid td { border: 1px solid #e5e7eb; }
        .month-name { background: #1e3a5f; color: #fff; font-weight: 600;
                      font-size: 13px; text-align: center; padding: 8px 4px; }
        .month-grid thead tr:last-child th {
          background: #f3f4f6; font-weight: 600; font-size: 11px;
          text-align: center; padding: 4px 2px; color: #6b7280; }
        .day  { vertical-align: top; width: 45px; min-height: 54px;
                padding: 3px 3px 4px; }
        .day.today     { background: #fef9c3; }
        .day.past      { background: #fafafa; }
        .day.has-tasks { }
        .blank { background: #f9fafb; }
        .day-num { font-size: 11px; font-weight: 600; color: #374151;
                   text-align: right; padding-right: 2px; }
        .today .day-num { color: #b45309; }
        .chips  { display: flex; flex-direction: column; gap: 2px; margin-top: 2px; }
        .chip   { font-size: 10px; padding: 1px 4px; border-radius: 3px;
                  line-height: 1.4; white-space: nowrap; overflow: hidden;
                  text-overflow: ellipsis; max-width: 100%; cursor: default; }
        .no-date { margin-top: 8px; }
        .no-date-table { border-collapse: collapse; width: 100%; max-width: 680px;
                         background: #fff; border-radius: 8px; overflow: hidden;
                         box-shadow: 0 1px 3px rgba(0,0,0,.1); }
        .no-date-table th, .no-date-table td {
          border: 1px solid #e5e7eb; padding: 7px 12px; text-align: left; }
        .no-date-table thead th { background: #f3f4f6; font-weight: 600; font-size: 12px; }
        @media print {
          body { background: white; padding: 0; }
          .month-grid { box-shadow: none; border: 1px solid #ccc; }
        }
      </style>
    </head>
    <body>
      <h1>Outstanding Tasks</h1>
      <p class="subtitle">Generated #{TODAY.strftime('%B %-d, %Y')} &nbsp;·&nbsp;
         #{outstanding.size} outstanding &nbsp;·&nbsp;
         #{tasks_with_dates.size} with due dates</p>
      <div class="legend">#{legend_html}</div>
      #{month_grids_html(tasks_by_date, cal_start, cal_end)}
      #{no_date_section_html(tasks_without)}
    </body>
    </html>
  HTML
end

# Determine calendar range
tasks_with_due = outstanding.filter_map { |t| parse_date(t.due_at) }
earliest_due   = tasks_with_due.min || TODAY
latest_due     = tasks_with_due.max || (TODAY >> 1)

cal_start = if ENV['CALENDAR_START']
              Date.parse(ENV['CALENDAR_START'])
            else
              [earliest_due, TODAY].min
            end

cal_end = if ENV['CALENDAR_END']
            Date.parse(ENV['CALENDAR_END'])
          else
            [latest_due, TODAY].max
          end

cal_file = ENV.fetch('CALENDAR_FILE', 'tasks_calendar.html')
html     = build_html_calendar(outstanding, cal_start, cal_end)
File.write(cal_file, html)

puts '─' * 72
puts "  HTML CALENDAR  →  #{cal_file}"
puts "  Range: #{cal_start.strftime('%b %-d, %Y')} – #{cal_end.strftime('%b %-d, %Y')}"
puts '  Open in any browser. Override range with CALENDAR_START / CALENDAR_END.'
puts
