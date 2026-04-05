# examples/reporting/outstanding_tasks.rb
# frozen_string_literal: true

# Printavo Outstanding Tasks Report
# ====================================
# Pages through all tasks, filters to incomplete ones, and renders a
# prioritized report grouped by urgency:
#
#   OVERDUE      — past due date, not yet complete
#   DUE TODAY    — due date is today
#   DUE THIS WEEK — due within the next 7 days
#   UPCOMING     — due more than 7 days from now
#   NO DUE DATE  — no deadline set
#
# Each section is sorted by due date (oldest first for overdue, soonest
# first for upcoming). A summary table by assignee is printed at the end.
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
buckets[:overdue]    .sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:today]      .sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:this_week]  .sort_by! { |t| parse_date(t.due_at) || TODAY }
buckets[:upcoming]   .sort_by! { |t| parse_date(t.due_at) || Date::Infinity.new }
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
  label = if days < 0
            "#{days.abs}d overdue"
          elsif days.zero?
            'today'
          else
            "in #{days}d"
          end
  "#{due.strftime('%b %-d')}  #{label}"
end

def print_task(task, index)
  puts format('  %3d. %-42s  %-16s  %s',
              index,
              task.body.to_s.slice(0, 42),
              assignee_name(task),
              format_due(task))
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
puts format('  Total outstanding: %d  |  Overdue: %d  |  Due today: %d  |  Upcoming: %d',
            outstanding.size,
            buckets[:overdue].size,
            buckets[:today].size,
            buckets[:this_week].size + buckets[:upcoming].size)
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
    puts format('  %-30s %3d task%s%s',
                name,
                tasks.size,
                tasks.size == 1 ? '' : 's',
                overdue_str)
  end
puts
