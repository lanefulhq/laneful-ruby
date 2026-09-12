# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-09-10

### Added
- `from_header` on emails and request-level `MailSettings` (`sandbox_mode`, `return_message_ids`)
- `unsubscribe_group_id` and `unsubscribe_group_name` on tracking settings
- Organization APIs on the same client: unsubscribe groups, domains, and deliverability analytics
- Webhook event type `request`
- Optional attachment `inline_id`
- Examples for mail settings, domains, unsubscribe groups, and analytics

### Changed
- User-Agent is now `laneful-ruby/1.2.0` (derived from `Laneful::VERSION`)
- `webhook_data` is limited to 20 keys
- HTTP requests are instance-scoped so send and org clients can be used together

## [1.1.0] - 2024-12-19

### Added
- **Enhanced Webhook Support**: Complete webhook handling functionality matching PHP and Java implementations
- **Signature Prefix Support**: Added support for `sha256=` prefix in webhook signatures
- **Payload Parsing**: New `parse_webhook_payload()` method for comprehensive webhook payload parsing
- **Batch Mode Support**: Support for both single event and batch mode webhook payloads
- **Event Type Validation**: Validation against all documented event types (delivery, open, click, drop, spam_complaint, unsubscribe, bounce)
- **Field Validation**: Email format, UUID format, and timestamp validation for webhook events
- **Header Extraction**: New `extract_signature_from_headers()` method with support for multiple header formats
- **Signature Header Name**: New `signature_header_name()` method for getting the correct header name
- **Enhanced Security**: Constant-time string comparison to prevent timing attacks
- **Comprehensive Documentation**: Full YARD documentation for all webhook methods
- **Complete Test Suite**: 33 comprehensive tests covering all webhook functionality
- **Webhook Example**: Full Sinatra-based webhook server example with all event handlers

### Enhanced
- **WebhookVerifier Class**: Expanded from 3 methods to 8 methods with full functionality
- **Error Handling**: More specific error messages and comprehensive validation
- **Backward Compatibility**: All existing functionality remains unchanged

### Technical Details
- Added support for `x-webhook-signature`, `X_WEBHOOK_SIGNATURE`, and `HTTP_X_WEBHOOK_SIGNATURE` header formats
- Implemented validation for required fields: `event`, `email`, `lane_id`, `message_id`, `timestamp`
- Added support for optional fields: `metadata`, `tag`, `url`, `is_hard`, `text`, `reason`, `unsubscribe_group_id`, `client_device`, `client_os`, `client_ip`
- Enhanced `generate_signature()` method with optional prefix support

## [1.0.1] - Previous Release

### Added
- Initial release with basic webhook signature verification
- Core email sending functionality
- Basic client implementation

---

For more information about webhook implementation, see the [webhook example](examples/webhook_example.rb).
