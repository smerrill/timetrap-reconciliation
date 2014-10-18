require 'rubygems'
require 'sqlite3'

primary = SQLite3::Database.new '.timetrap.db'
secondary = SQLite3::Database.new '.timetrap.db.knox-box'

# Use a set to only allow unique entries by date/time.
entries = {}
new_entries = {}

primary.execute 'SELECT * FROM entries' do |row|
  entries[row[2]] = row
end

puts "#{entries.count} existing entries found."

secondary.execute 'SELECT * FROM entries' do |row|
  unless entries.key?(row[2])
    # Set the ID to NULL so that we can insert it anew.
    row[0] = nil
    new_entries[row[2]] = row
  end
end

puts "#{new_entries.count} will be added to the Timetrap database."

new_entries.each do |_, row|
  primary.execute 'INSERT INTO entries (note, start, end, sheet) VALUES (?, ?, ?, ?)', [row[1], row[2], row[3], row[4]]
end

puts 'Success!'
