# examples/reporting/sales_report.rb
# frozen_string_literal: true

# Printavo Sales Report Example
# ==============================
# Pages through all invoices and computes sales totals for standard
# reporting periods: today, this week, this month, this quarter, YTD,
# last year, and a configurable date range.
#
# Why client-side? The Printavo V2 GraphQL API is a transactional API —
# it exposes no pre-aggregated analytics endpoints. All reporting is
# computed locally by paging through invoices in Ruby. For shops with
# large invoice histories, the built-in cache adapter can eliminate
# repeat API calls between report runs:
#
#   client = Printavo::Client.new(
#     email: ..., token: ..., cache: Printavo::MemoryStore.new
#   )
#
# Setup:
#   gem install printavo-ruby dotenv
#   cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
#   ruby sales_report.rb

require 'date'
require 'dotenv/load'
require 'printavo'

client = Printavo::Client.new(
  email: ENV.fetch('PRINTAVO_EMAIL'),
  token: ENV.fetch('PRINTAVO_TOKEN'),
  cache: Printavo::MemoryStore.new  # avoids re-fetching on repeated runs
)

# ── Date Period Helpers ───────────────────────────────────────────────────────

module Periods
  TODAY    = Date.today
  YEAR     = TODAY.year
  MONTH    = TODAY.month
  DAY      = TODAY.day

  def self.today        = [TODAY, TODAY]
  def self.this_week    = [TODAY - TODAY.wday + 1, TODAY]  # Monday → today
  def self.this_month   = [Date.new(YEAR, MONTH, 1), TODAY]
  def self.this_quarter
    q_start_month = ((MONTH - 1) / 3) * 3 + 1
    [Date.new(YEAR, q_start_month, 1), TODAY]
  end
  def self.ytd          = [Date.new(YEAR, 1, 1), TODAY]
  def self.last_year    = [Date.new(YEAR - 1, 1, 1), Date.new(YEAR - 1, 12, 31)]
  def self.custom(start_str, end_str)
    [Date.parse(start_str), Date.parse(end_str)]
  end
end

# ── Invoice Fetching ──────────────────────────────────────────────────────────
#
# The API returns invoices in descending order (newest first). We page through
# all of them and filter by invoiceAt (the date the invoice was issued).
# If invoiceAt is nil we fall back to createdAt.
#
# For very large histories, consider stopping pagination early once the
# oldest invoice on a page predates your earliest report period.

puts "Fetching invoices from Printavo (this may take a moment)..."
all_invoices = client.invoices.all_pages(first: 100)
puts "Fetched #{all_invoices.size} invoices total.\n\n"

def invoice_date(invoice)
  raw = invoice.invoice_at || invoice.created_at
  return nil if raw.nil?

  Date.parse(raw.to_s[0, 10])
rescue Date::Error
  nil
end

def in_period?(invoice, start_date, end_date)
  d = invoice_date(invoice)
  d && d >= start_date && d <= end_date
end

# ── Report Builder ────────────────────────────────────────────────────────────

def build_report(invoices, start_date, end_date)
  subset = invoices.select { |inv| in_period?(inv, start_date, end_date) }

  totals   = subset.map { |inv| inv.total.to_f }
  paid     = subset.map { |inv| inv.amount_paid.to_f }
  owed     = subset.map { |inv| inv.amount_outstanding.to_f }
  count    = subset.size
  paid_cnt = subset.count(&:paid_in_full?)

  {
    period:             "#{start_date} → #{end_date}",
    invoice_count:      count,
    gross_revenue:      totals.sum,
    amount_paid:        paid.sum,
    amount_outstanding: owed.sum,
    paid_in_full_count: paid_cnt,
    average_invoice:    count.positive? ? totals.sum / count : 0.0,
    largest_invoice:    totals.max || 0.0
  }
end

# ── Formatter ─────────────────────────────────────────────────────────────────

def fmt_currency(amount)
  format('$%,.2f', amount)
end

def print_report(label, report)
  separator = '─' * 52
  puts separator
  puts "  #{label.upcase}"
  puts "  #{report[:period]}"
  puts separator
  puts format('  %-28s %s', 'Invoices:', report[:invoice_count])
  puts format('  %-28s %s', 'Gross Revenue:', fmt_currency(report[:gross_revenue]))
  puts format('  %-28s %s', 'Amount Paid:', fmt_currency(report[:amount_paid]))
  puts format('  %-28s %s', 'Amount Outstanding:', fmt_currency(report[:amount_outstanding]))
  puts format('  %-28s %s', 'Paid in Full:', report[:paid_in_full_count])
  puts format('  %-28s %s', 'Average Invoice:', fmt_currency(report[:average_invoice]))
  puts format('  %-28s %s', 'Largest Invoice:', fmt_currency(report[:largest_invoice]))
  puts
end

# ── Run Reports ───────────────────────────────────────────────────────────────

periods = {
  'Today'        => Periods.today,
  'This Week'    => Periods.this_week,
  'This Month'   => Periods.this_month,
  'This Quarter' => Periods.this_quarter,
  'Year to Date' => Periods.ytd,
  'Last Year'    => Periods.last_year
}

# Custom date range from ENV (optional)
if ENV['REPORT_START'] && ENV['REPORT_END']
  periods['Custom Range'] = Periods.custom(ENV['REPORT_START'], ENV['REPORT_END'])
end

periods.each do |label, (start_date, end_date)|
  report = build_report(all_invoices, start_date, end_date)
  print_report(label, report)
end

# ── Status Breakdown (bonus) ──────────────────────────────────────────────────

puts '─' * 52
puts '  YTD REVENUE BY STATUS'
puts '─' * 52

ytd_start, ytd_end = Periods.ytd
ytd_invoices = all_invoices.select { |inv| in_period?(inv, ytd_start, ytd_end) }

ytd_invoices
  .group_by(&:status)
  .sort_by { |_, invs| -invs.sum { |inv| inv.total.to_f } }
  .each do |status, invs|
    total = invs.sum { |inv| inv.total.to_f }
    puts format('  %-30s %s (%d)', status.to_s, fmt_currency(total), invs.size)
  end
puts
