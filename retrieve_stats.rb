#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML( open( 'http://rubygems.org/gems/cerberus' ) )

doc.css( 'h3' ).each do |h3|
  puts "version: #{h3}"
end

doc.css( 'span:nth-child(1) strong' ).each do |elm|
  puts "total downloads: #{elm}"
end

doc.css( 'span:nth-child(2) strong' ).each do |elm|
  puts "version downloads: #{elm}"
end
