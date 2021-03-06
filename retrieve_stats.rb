#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

TODAY = Date.today.strftime( "%Y%m%d" )
DEBUG = ARGV.include?( '--debug' )

#
# setup sqlite DB connection
#
# * date varchar(8) primary key,
# * version varchar(12),
# * total_downloads integer,
# * version_downloads integer
dbfile = File.join( File.expand_path( File.dirname(__FILE__) ), "stats.db" )
puts dbfile if DEBUG
db = SQLite3::Database.new( dbfile )

# grab rubygems.org page and parse stats
doc = Nokogiri::HTML( open( 'http://rubygems.org/gems/cerberus' ) )
doc.css( 'h3' ).each do |elm|
  @version = elm.content
  puts "version: #{@version}" if DEBUG
end

doc.css( 'span:nth-child(1) strong' ).each do |elm|
  @total_downloads = elm.content.gsub( /,/, '' ).to_i
  puts "total downloads: #{@total_downloads}" if DEBUG
end

doc.css( 'span:nth-child(2) strong' ).each do |elm|
  @version_downloads = elm.content.gsub( /,/, '' ).to_i
  puts "version downloads: #{@version_downloads}" if DEBUG
end

# store stats in the DB
row = db.execute( "select * from stats where date = '#{TODAY}' AND version = '#{@version}'" )
if row.empty? # insert new record
  db.execute( "insert into stats values ('#{TODAY}', '#{@version}', #{@total_downloads}, #{@version_downloads})" )
else        # update existing record
  db.execute( "update stats set total_downloads = #{@total_downloads}, version_downloads = #{@version_downloads} where date = '#{TODAY}' AND version = '#{@version}'" )
end
