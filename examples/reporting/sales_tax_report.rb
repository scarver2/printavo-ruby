# examples/reporting/sales_tax_report.rb
# frozen_string_literal: true

# Printavo Sales Tax Report Example
# ===================================
# Pages through all invoices and computes taxable sales totals for the same
# standard reporting periods as sales_report.rb: today, this week, this month,
# this quarter, YTD, last year, and a configurable date range.
#
# How Printavo handles tax:
# ─────────────────────────
# Printavo stores tax at the line-item and fee level — not as a standalone
# `taxTotal` field on the invoice. This means a complete tax report requires
# fetching fees for each invoice (one additional API call per invoice).
#
# This script shows two approaches:
#
#   1. INVOICE-LEVEL SUMMARY (fast, no extra API calls)
#      Uses the invoice `total` as the tax base. Useful for estimating
#      tax liability when you collect tax on all sales.
#
#   2. FEE-LEVEL DETAIL (accurate, extra API calls)
#      Fetches fees per invoice and sums only those marked `taxable: true`.
#      Use the built-in cache adapter to avoid hammering the rate limit
#      when running this against large invoice histories.
#
# For shops that apply a flat sales tax rate, approach 1 is usually sufficient.
# For shops with mixed taxable/non-taxable items, use approach 2.
#
# Setup:
#   gem install printavo-ruby dotenv
#   cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
#   ruby sales_tax_report.rb

require 'date'
require 'dotenv/load'
require 'printavo'

TAX_RATE = (ENV.fetch('TAX_RATE', '8.25').to_f / 100).freeze  # e.g. 8.25%

client = Printavo::Client.new(
  email: ENV.fetch('PRINTAVO_EMAIL'),
  token: ENV.fetch('PRINTAVO_TOKEN'),
  cache: Printavo::MemoryStore.new  # essential for fee-level detail approach
)

# ── Date Period Helpers ───────────────────────────────────────────────────────

module Periods
  TODAY    = Date.today
  YEAR     = TODAY.year
  MONTH    = TODAY.month

  def self.today        = [TODAY, TODAY]
  def self.this_week    = [TODAY - TODAY.wday + 1, TODAY]
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

# ── Approach 1: Invoice-Level Summary ────────────────────────────────────────
#
# Computes estimated tax using the invoice `total` and the configured TAX_RATE.
# Fast — no additional API calls beyond the initial invoice page-through.
# Assumes tax is collected on all sales. Adjust the exclusion list as needed
# for out-of-state, tax-exempt customers, or non-taxable items.

def invoice_level_report(invoices, start_date, end_date, tax_rate)
  subset       = invoices.select { |inv| in_period?(inv, start_date, end_date) }
  totals       = subset.map { |inv| inv.total.to_f }
  gross        = totals.sum
  tax_estimate = gross * tax_rate

  {
    period:       "#{start_date} → #{end_date}",
    invoices:     subset.size,
    gross_sales:  gross,
    tax_rate:     tax_rate,
    tax_estimate: tax_estimate
  }
end

# ── Approach 2: Fee-Level Detail ──────────────────────────────────────────────
#
# For each invoice in the period, fetches its fees and sums those marked
# `taxable: true`. This reflects the actual tax applied in Printavo.
#
# NOTE: This issues one additional API call per invoice. For 200 invoices
# that is ~200 extra requests. The MemoryStore cache above ensures that
# re-running the report within the process does not re-fetch.
#
# For production use, pass `cache: Rails.cache` (or another persistent store)
# to the Printavo::Client so the fee data survives between process runs.

def fee_level_detail(invoices, start_date, end_date, client)
  subset = invoices.select { |inv| in_period?(inv, start_date, end_date) }
  rows   = []

  subset.each do |invoice|
    fees          = client.fees.all(order_id: invoice.id)
    taxable_fees  = fees.select { |f| f.taxable? }
    taxable_total = taxable_fees.sum { |f| f.amount.to_f }

    rows << {
      visual_id:     invoice.visual_id,
      date:          invoice_date(invoice),
      invoice_total: invoice.total.to_f,
      taxable_total: taxable_total,
      fee_count:     fees.size,
      taxable_fees:  taxable_fees.size
    }
  end

  rows
end

# ── Formatter ─────────────────────────────────────────────────────────────────

def fmt_currency(amount)
  format('$%,.2f', amount)
end

def fmt_pct(rate)
  format('%.4f%%', rate * 100)
end

def print_summary(label, report)
  separator = '─' * 52
  puts separator
  puts "  #{label.upcase}"
  puts "  #{report[:period]}"
  puts separator
  puts format('  %-30s %d', 'Invoices:', report[:invoices])
  puts format('  %-30s %s', 'Gross Sales:', fmt_currency(report[:gross_sales]))
  puts format('  %-30s %s', 'Applied Tax Rate:', fmt_pct(report[:tax_rate]))
  puts format('  %-30s %s', 'Estimated Tax Collected:', fmt_currency(report[:tax_estimate]))
  puts
end

# ── Run Approach 1: Invoice-Level Summary ─────────────────────────────────────

puts "APPROACH 1 — Invoice-Level Estimates  (tax rate: #{fmt_pct(TAX_RATE)})"
puts "(Set TAX_RATE env var to your effective rate, e.g. TAX_RATE=8.25)\n\n"

periods = {
  'Today'        => Periods.today,
  'This Week'    => Periods.this_week,
  'This Month'   => Periods.this_month,
  'This Quarter' => Periods.this_quarter,
  'Year to Date' => Periods.ytd,
  'Last Year'    => Periods.last_year
}

if ENV['REPORT_START'] && ENV['REPORT_END']
  periods['Custom Range'] = Periods.custom(ENV['REPORT_START'], ENV['REPORT_END'])
end

periods.each do |label, (start_date, end_date)|
  report = invoice_level_report(all_invoices, start_date, end_date, TAX_RATE)
  print_summary(label, report)
end

# ── Run Approach 2: Fee-Level Detail (YTD only to limit API calls) ─────────────
#
# Running fee-level detail for all periods would duplicate API calls.
# Fetch once for the widest period (YTD) and slice in Ruby for sub-periods.
# Remove the YTD guard below to run all periods if your history is small.

puts '─' * 52
puts '  APPROACH 2 — Fee-Level Detail  (YTD)'
puts "  (fetches fees per invoice — uses cache to limit API calls)\n"
puts '─' * 52

ytd_start, ytd_end = Periods.ytd
rows = fee_level_detail(all_invoices, ytd_start, ytd_end, client)

if rows.empty?
  puts '  No invoices found for YTD period.'
else
  taxable_sum      = rows.sum { |r| r[:taxable_total] }
  invoice_sum      = rows.sum { |r| r[:invoice_total] }
  fully_taxed      = rows.count { |r| r[:taxable_total] == r[:invoice_total] }
  partially_taxed  = rows.count { |r| r[:taxable_total].positive? && r[:taxable_total] < r[:invoice_total] }
  untaxed          = rows.count { |r| r[:taxable_total].zero? }

  puts format('  %-30s %d', 'Invoices analyzed:', rows.size)
  puts format('  %-30s %s', 'Total Invoiced (YTD):', fmt_currency(invoice_sum))
  puts format('  %-30s %s', 'Total Taxable Amount:', fmt_currency(taxable_sum))
  puts format('  %-30s %s', 'Tax at Applied Rate:', fmt_currency(taxable_sum * TAX_RATE))
  puts
  puts format('  %-30s %d', 'Fully taxable invoices:', fully_taxed)
  puts format('  %-30s %d', 'Partially taxable:', partially_taxed)
  puts format('  %-30s %d', 'No taxable fees:', untaxed)
  puts

  # Optional: print per-invoice detail (comment out for large histories)
  if rows.size <= 50
    puts '  INVOICE DETAIL'
    puts format('  %-12s %-12s %14s %14s', 'Invoice #', 'Date', 'Total', 'Taxable')
    puts "  #{'-' * 54}"
    rows.sort_by { |r| r[:date] || Date.new(0) }.each do |r|
      puts format('  %-12s %-12s %14s %14s',
                  r[:visual_id],
                  r[:date].to_s,
                  fmt_currency(r[:invoice_total]),
                  fmt_currency(r[:taxable_total]))
    end
    puts
  end
end
