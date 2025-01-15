#!/usr/bin/ruby

require_relative './utils.rb'

if ARGV.length < 1
    puts 'usage: jq { db | path/to/json } { [optional] query params }'
    exit(1)
end

dbpath = "#{__dir__}/db.json"
db = json(dbpath)

arg1 = ARGV[0].downcase
query = (ARGV&.length || 1) == 1 ? [] : ARGV[1..]

path = case
when arg1 == 'db'
  if query.empty?
    puts JSON.pretty_generate(db)
    exit(0)
  end
  if query.length < 2
    puts 'usage: jq db { key } { delete | path/to/json }'
    exit(1)
  end
  if query[1] == "delete"
    db.delete(query[0])
  elsif json(query[1])
    db[query[0]] = nil
  end
  File.write(dbpath, db.to_json())
  puts JSON.pretty_generate(db)
  exit(0)
else
  db[arg1] || ARGV[0]
end

ptr = json(path)
key = '*'
query.each do |q|
  res = ptr.query(q)
  break if res[:value].nil?
  key = res[:key]
  ptr = res[:value]
end

res = {}
res[key] = ptr
puts JSON.pretty_generate(res)

