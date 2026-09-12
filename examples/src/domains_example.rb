#!/usr/bin/env ruby
# frozen_string_literal: true

require '/app/lib/laneful'

puts '📧 Laneful Ruby SDK - Domains Example'
puts '===================================='

base_url = ENV['LANEFUL_ORG_BASE_URL'] || ENV['LANEFUL_BASE_URL'] || 'https://api.laneful.net'
auth_token = ENV['LANEFUL_AUTH_TOKEN']
workspace_id = (ENV['LANEFUL_WORKSPACE_ID'] || '1').to_i

if auth_token.nil?
  puts '❌ Missing LANEFUL_AUTH_TOKEN'
  exit 1
end

begin
  client = Laneful::Client.new(base_url, auth_token)

  list = client.list_domains(workspace_id, Laneful::ListDomainsParams.new(limit: 50))
  puts "Domains: #{list.domains.size}"

  domain = client.create_domain(
    workspace_id,
    Laneful::CreateDomainRequest.new(domain: 'mydomain.com', tracking: 'tracking', return_path: 'return-path')
  )
  puts "Created #{domain.domain}, verified=#{domain.verified}"

  domain = client.verify_domain(workspace_id, 'mydomain.com')
  puts "Verification: dmarc=#{domain.dmarc_verified}"

  domain = client.update_domain(
    workspace_id,
    'mydomain.com',
    Laneful::UpdateDomainRequest.new('e59f0a35-05bc-4516-b585-c06f69c3e67e')
  )
  puts "Email track: #{domain.email_track_id}"
rescue Laneful::ApiException, Laneful::HttpException => e
  puts "✗ Domain API error: #{e.message}"
end
