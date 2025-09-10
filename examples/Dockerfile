# Use official Ruby image
FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the main SDK files
COPY lib/ ./lib/
COPY laneful-ruby.gemspec ./
COPY Gemfile ./
COPY Gemfile.lock ./

# Copy examples
COPY examples/ ./examples/

# Install the SDK gem locally
RUN gem build laneful-ruby.gemspec && \
    gem install laneful-ruby-*.gem && \
    gem install --local laneful-ruby-*.gem

# Install example dependencies
WORKDIR /app/examples
RUN bundle install

# Verify gem installation
RUN gem list laneful-ruby

# Create a script to run examples
RUN echo '#!/bin/bash' > /app/run-example.sh && \
    echo 'cd /app/examples' >> /app/run-example.sh && \
    echo 'echo "🔧 Environment variables:"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_BASE_URL: ${LANEFUL_BASE_URL:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_AUTH_TOKEN: ${LANEFUL_AUTH_TOKEN:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_FROM_EMAIL: ${LANEFUL_FROM_EMAIL:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_TO_EMAILS: ${LANEFUL_TO_EMAILS:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_TEMPLATE_ID: ${LANEFUL_TEMPLATE_ID:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_WEBHOOK_SECRET: ${LANEFUL_WEBHOOK_SECRET:-not set}"' >> /app/run-example.sh && \
    echo 'echo "  LANEFUL_WEBHOOK_URL: ${LANEFUL_WEBHOOK_URL:-not set}"' >> /app/run-example.sh && \
    echo 'echo ""' >> /app/run-example.sh && \
    echo 'if [ "$1" = "BasicEmailExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Basic Email Example..."' >> /app/run-example.sh && \
    echo '  ruby src/basic_email_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "HTMLEmailWithTrackingExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running HTML Email with Tracking Example..."' >> /app/run-example.sh && \
    echo '  ruby src/html_email_with_tracking_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "TemplateEmailExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Template Email Example..."' >> /app/run-example.sh && \
    echo '  ruby src/template_email_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "AttachmentEmailExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Attachment Email Example..."' >> /app/run-example.sh && \
    echo '  ruby src/attachment_email_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "MultipleRecipientsExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Multiple Recipients Example..."' >> /app/run-example.sh && \
    echo '  ruby src/multiple_recipients_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "ScheduledEmailExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Scheduled Email Example..."' >> /app/run-example.sh && \
    echo '  ruby src/scheduled_email_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "BatchEmailExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Batch Email Example..."' >> /app/run-example.sh && \
    echo '  ruby src/batch_email_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "WebhookHandlerExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Webhook Handler Example..."' >> /app/run-example.sh && \
    echo '  ruby src/webhook_handler_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "ErrorHandlingExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Error Handling Example..."' >> /app/run-example.sh && \
    echo '  ruby src/error_handling_example.rb' >> /app/run-example.sh && \
    echo 'elif [ "$1" = "ComprehensiveExample" ]; then' >> /app/run-example.sh && \
    echo '  echo "🚀 Running Comprehensive Example..."' >> /app/run-example.sh && \
    echo '  ruby src/comprehensive_example.rb' >> /app/run-example.sh && \
    echo 'else' >> /app/run-example.sh && \
    echo '  echo "Available examples:"' >> /app/run-example.sh && \
    echo '  echo "  BasicEmailExample"' >> /app/run-example.sh && \
    echo '  echo "  HTMLEmailWithTrackingExample"' >> /app/run-example.sh && \
    echo '  echo "  TemplateEmailExample"' >> /app/run-example.sh && \
    echo '  echo "  AttachmentEmailExample"' >> /app/run-example.sh && \
    echo '  echo "  MultipleRecipientsExample"' >> /app/run-example.sh && \
    echo '  echo "  ScheduledEmailExample"' >> /app/run-example.sh && \
    echo '  echo "  BatchEmailExample"' >> /app/run-example.sh && \
    echo '  echo "  WebhookHandlerExample"' >> /app/run-example.sh && \
    echo '  echo "  ErrorHandlingExample"' >> /app/run-example.sh && \
    echo '  echo "  ComprehensiveExample"' >> /app/run-example.sh && \
    echo 'fi' >> /app/run-example.sh && \
    chmod +x /app/run-example.sh

# Set the default command
ENTRYPOINT ["/app/run-example.sh"]
