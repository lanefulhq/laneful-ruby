#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

puts '📧 Laneful Ruby SDK - Unsubscribe Groups Example'
puts '================================================'

base_url = ENV['LANEFUL_ORG_BASE_URL'] || ENV['LANEFUL_BASE_URL'] || 'https://api.laneful.net'
auth_token = ENV['LANEFUL_AUTH_TOKEN']
workspace_id = (ENV['LANEFUL_WORKSPACE_ID'] || '1').to_i

if auth_token.nil?
  puts '❌ Missing LANEFUL_AUTH_TOKEN'
  exit 1
end

begin
  client = Laneful::Client.new(base_url, auth_token)

  created = client.create_unsubscribe_group(workspace_id, 'Newsletters')
  puts "Created group #{created.unsubscribe_group_id}: #{created.name}"

  updated = client.update_unsubscribe_group(workspace_id, created.unsubscribe_group_id, 'Weekly Newsletters')
  puts "Updated name: #{updated.name}"

  list = client.list_unsubscribe_groups(workspace_id, Laneful::ListUnsubscribeGroupsParams.new(limit: 50))
  list.unsubscribe_groups.each do |group|
    puts "- #{group.unsubscribe_group_id} #{group.name}"
  end
rescue Laneful::ApiException, Laneful::HttpException => e
  puts "✗ Unsubscribe group API error: #{e.message}"
end
