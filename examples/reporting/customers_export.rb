# examples/reporting/customers_export.rb
# frozen_string_literal: true

# Printavo Customer Export Example
# ==================================
# Pages through all Printavo customers and exports to seven formats:
#
#   customers.csv          — Universal CSV (Ruby stdlib, no gem required)
#   customers.xlsx         — Excel workbook (requires: gem install caxlsx)
#   customers.xls          — Legacy Excel 97–2003 (requires: gem install spreadsheet)
#   customers.vcf          — vCard 3.0 — imports into any CRM, email client, or phone
#   customers_hubspot.csv  — HubSpot Contacts import CSV
#   customers_salesforce.csv — Salesforce Leads/Contacts import CSV
#   customers_mailchimp.csv  — Mailchimp audience import CSV
#
# All files are written to the directory where this script is run.
#
# Setup:
#   gem install printavo-ruby dotenv
#   cp .env.example .env   # fill in PRINTAVO_EMAIL and PRINTAVO_TOKEN
#   ruby customers_export.rb
#
# For XLSX output:  gem install caxlsx
# For XLS output:   gem install spreadsheet

require 'csv'
require 'dotenv/load'
require 'printavo'

client = Printavo::Client.new(
  email: ENV.fetch('PRINTAVO_EMAIL'),
  token: ENV.fetch('PRINTAVO_TOKEN'),
  cache: Printavo::MemoryStore.new
)

puts 'Fetching customers from Printavo...'
customers = client.customers.all_pages(first: 100)
puts "Fetched #{customers.size} customers.\n\n"

abort 'No customers found. Check your credentials.' if customers.empty?

# ── Column Definitions ────────────────────────────────────────────────────────
#
# Canonical column order used for CSV, XLS, and XLSX.
# Add or remove fields here to customize all spreadsheet exports at once.

COLUMNS = [
  ['ID',         ->(c) { c.id }],
  ['First Name', ->(c) { c.first_name }],
  ['Last Name',  ->(c) { c.last_name }],
  ['Full Name',  ->(c) { c.full_name }],
  ['Company',    ->(c) { c.company }],
  ['Email',      ->(c) { c.email }],
  ['Phone',      ->(c) { c.phone }],
  ['Created At', ->(c) { c.created_at }],
  ['Updated At', ->(c) { c.updated_at }]
].freeze

# ── CSV (Universal) ───────────────────────────────────────────────────────────
#
# Accepted by every CRM, database tool, and spreadsheet application.
# The safest format for bulk imports when a dedicated format isn't required.

def export_csv(customers, path)
  CSV.open(path, 'w') do |csv|
    csv << COLUMNS.map(&:first)
    customers.each { |c| csv << COLUMNS.map { |_, fn| fn.call(c) } }
  end
end

# ── XLSX (Excel / Google Sheets) ──────────────────────────────────────────────
#
# Requires: gem install caxlsx
# caxlsx is the maintained fork of the axlsx gem.
# Produces a proper .xlsx workbook with column widths and a frozen header row.

def export_xlsx(customers, path)
  require 'caxlsx'

  package  = Caxlsx::Package.new
  workbook = package.workbook

  workbook.styles do |s|
    header_style = s.add_style(bg_color: '4472C4', fg_color: 'FFFFFF',
                               b: true, alignment: { horizontal: :center })
    workbook.add_worksheet(name: 'Customers') do |sheet|
      sheet.add_row(COLUMNS.map(&:first), style: header_style)
      customers.each { |c| sheet.add_row(COLUMNS.map { |_, fn| fn.call(c) }) }
      sheet.column_widths(*([18] * COLUMNS.size))
      sheet.sheet_view.freeze_rows = 1
    end
  end

  package.serialize(path)
end

# ── XLS (Legacy Excel 97–2003) ────────────────────────────────────────────────
#
# Requires: gem install spreadsheet
# Use this when a downstream system specifically requires the older .xls format.
# For everything else, prefer .xlsx.

def export_xls(customers, path)
  require 'spreadsheet'

  book  = Spreadsheet::Workbook.new
  sheet = book.create_worksheet(name: 'Customers')

  header_format        = Spreadsheet::Format.new(weight: :bold)
  sheet.row(0).default_format = header_format
  sheet.row(0).push(*COLUMNS.map(&:first))

  customers.each_with_index do |c, i|
    sheet.row(i + 1).push(*COLUMNS.map { |_, fn| fn.call(c) })
  end

  book.write(path)
end

# ── vCard 3.0 (.vcf) ──────────────────────────────────────────────────────────
#
# The universal contact exchange format. Imports into:
#   - Apple Contacts / iCloud
#   - Google Contacts
#   - Outlook
#   - HubSpot, Salesforce, Zoho, Pipedrive (via contacts import)
#   - Any smartphone address book
#
# One vCard block per customer. All in a single .vcf file.

def vcard_escape(str)
  str.to_s.gsub(',', '\\,').gsub(';', '\\;').gsub("\n", '\\n')
end

def to_vcard(customer)
  lines = ['BEGIN:VCARD', 'VERSION:3.0']
  lines << "FN:#{vcard_escape(customer.full_name)}"
  lines << "N:#{vcard_escape(customer.last_name)};#{vcard_escape(customer.first_name)};;;"
  lines << "ORG:#{vcard_escape(customer.company)}"  if customer.company.to_s.strip.length.positive?
  lines << "EMAIL;TYPE=INTERNET:#{customer.email}"  if customer.email.to_s.strip.length.positive?
  lines << "TEL;TYPE=WORK,VOICE:#{customer.phone}"  if customer.phone.to_s.strip.length.positive?
  lines << "X-PRINTAVO-ID:#{customer.id}"
  lines << "REV:#{customer.updated_at}" if customer.updated_at
  lines << 'END:VCARD'
  lines.join("\r\n")
end

def export_vcf(customers, path)
  File.write(path, customers.map { |c| to_vcard(c) }.join("\r\n\r\n"))
end

# ── HubSpot CSV ───────────────────────────────────────────────────────────────
#
# HubSpot's Contacts import expects specific property names as column headers.
# Reference: https://knowledge.hubspot.com/contacts/how-do-i-import-contacts
#
# After export: HubSpot → Contacts → Import → File → Contacts (single object)

def export_hubspot(customers, path)
  CSV.open(path, 'w') do |csv|
    csv << %w[First\ Name Last\ Name Email Phone\ Number Company
              Contact\ Owner Lifecycle\ Stage]
    customers.each do |c|
      csv << [c.first_name, c.last_name, c.email, c.phone, c.company, '', 'customer']
    end
  end
end

# ── Salesforce CSV ────────────────────────────────────────────────────────────
#
# Salesforce Leads/Contacts import. Column headers match Salesforce field API names.
# Reference: Salesforce → Setup → Data Import Wizard → Contacts & Leads
#
# Map to Contacts if customers already exist in Salesforce; Leads for net-new.

def export_salesforce(customers, path)
  CSV.open(path, 'w') do |csv|
    csv << %w[FirstName LastName Email Phone Account\ Name Description]
    customers.each do |c|
      csv << [c.first_name, c.last_name, c.email, c.phone, c.company,
              "Imported from Printavo — ID #{c.id}"]
    end
  end
end

# ── Mailchimp CSV ─────────────────────────────────────────────────────────────
#
# Mailchimp audience import. Required: EMAIL. All other columns are merge tags.
# Reference: Mailchimp → Audience → Add contacts → Import contacts
#
# After import, tag the audience segment "Printavo Customers" for filtering.

def export_mailchimp(customers, path)
  CSV.open(path, 'w') do |csv|
    csv << %w[Email\ Address First\ Name Last\ Name PHONE COMPANY]
    customers.each do |c|
      csv << [c.email, c.first_name, c.last_name, c.phone, c.company]
    end
  end
end

# ── Run All Exports ───────────────────────────────────────────────────────────

exports = [
  ['customers.csv',              'CSV (Universal)',        method(:export_csv)],
  ['customers.vcf',              'vCard 3.0',              method(:export_vcf)],
  ['customers_hubspot.csv',      'HubSpot CSV',            method(:export_hubspot)],
  ['customers_salesforce.csv',   'Salesforce CSV',         method(:export_salesforce)],
  ['customers_mailchimp.csv',    'Mailchimp CSV',          method(:export_mailchimp)],
  ['customers.xlsx',             'XLSX  (gem: caxlsx)',    method(:export_xlsx)],
  ['customers.xls',              'XLS   (gem: spreadsheet)', method(:export_xls)]
]

separator = '─' * 52
puts separator
puts "  CUSTOMER EXPORT  (#{customers.size} records)"
puts separator

exports.each do |filename, label, fn|
  print format('  %-36s', label)
  begin
    fn.call(customers, filename)
    size = File.size(filename)
    puts format('%s  (%d bytes)', filename, size)
  rescue LoadError => e
    missing_gem = e.message.match(/cannot load such file -- (\S+)/i)&.[](1) || '?'
    puts "skipped — gem install #{missing_gem}"
  rescue StandardError => e
    puts "failed — #{e.message}"
  end
end

puts
