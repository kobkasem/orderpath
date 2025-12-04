# Use Ruby 3.2.0
FROM ruby:3.2.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  postgresql-client \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]


