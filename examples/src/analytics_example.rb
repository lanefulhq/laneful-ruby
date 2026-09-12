#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require '/app/lib/laneful'

puts '📧 Laneful Ruby SDK - Analytics Example'
puts '======================================'

base_url = ENV['LANEFUL_ORG_BASE_URL'] || ENV['LANEFUL_BASE_URL'] || 'https://api.laneful.net'
auth_token = ENV['LANEFUL_AUTH_TOKEN']

if auth_token.nil?
  puts '❌ Missing LANEFUL_AUTH_TOKEN'
  exit 1
end

begin
  client = Laneful::Client.new(base_url, auth_token)
  start_date = (Date.today - 7).to_s
  end_date = Date.today.to_s

  radar = client.list_domain_spam_ratio_radar(
    Laneful::ListDomainSpamRatioRadarParams.new(start_date: start_date, end_date: end_date)
  )
  radar.radar.each do |entry|
    puts "#{entry.date} #{entry.domain} @#{entry.esp}: #{entry.spam_ratio}%"
  end

  postmaster = client.list_google_postmaster_spam_reports(
    Laneful::ListGooglePostmasterSpamReportsParams.new(domain: 'example.com')
  )
  postmaster.spam_reports.each do |report|
    puts "#{report.date} #{report.domain}: #{report.spam_ratio}%"
  end

  snds = client.list_snds_reports(Laneful::ListSndsReportsParams.new)
  snds.snds_reports.each do |report|
    puts "#{report.date} #{report.ip}: filter=#{report.filter_result} complaint=#{report.complaint_rate}%"
  end
rescue Laneful::ApiException, Laneful::HttpException => e
  puts "✗ Analytics API error: #{e.message}"
end
