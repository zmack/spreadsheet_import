require 'open-uri'
require 'nokogiri'
require 'mysql2'


def fix_date(date)
  # 22.04.2013 => 2013-04-22
  date.split('.').reverse.join('-')
end

sheet_id = '1lVrCb2kJr9XKkKKILSflfluB4wMSb7mQOOoVWbq-OUA'
url = "https://spreadsheets.google.com/feeds/cells/#{sheet_id}/od6/public/full"
content = open(url).read

DB_USER = "root"
DB_PASSWORD = ""
DB_HOST = "localhost"
DB_DATABASE = "silly"
DB_TABLE = "silly"

xmldoc = Nokogiri::XML(content)

cells = xmldoc.xpath('//gs:cell')

rows = {}

cells.each do |cell|
  current_row = cell['row'].to_i
  current_col = cell['col'].to_i

  rows[current_row] ||= {}
  rows[current_row][current_col] = cell.children.first.text.strip
end

client = Mysql2::Client.new(:host => DB_HOST, :username => DB_USER, :password => DB_PASSWORD, :db => DB_DATABASE)
client.query("use #{DB_DATABASE}")
p rows.values

# ESCAPING
rows.values[1..-1].each do |row|
  next if row.values[1..-1].all?(&:empty?)
  p "insert into #{DB_TABLE} (name, thing) values ('#{client.escape(row[1].to_s)}', '#{client.escape(row[2].to_s)}', '#{client.escape(row[3].to_s)}')"
  # client.query("insert into #{DB_TABLE} (name, thing) values ('#{client.escape(row[1].to_s)}', '#{client.escape(row[2].to_s)}')")
end
