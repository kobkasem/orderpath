# Contributing to OrderPath

Thank you for your interest in contributing to OrderPath!

## Development Setup

1. Fork the repository
2. Clone your fork
3. Install dependencies: `bundle install`
4. Set up database: `rails db:create db:migrate db:seed`
5. Start Redis: `redis-server`
6. Start Rails: `rails server`
7. Start Sidekiq: `bundle exec sidekiq`

## Code Style

- Follow Ruby style guide: https://rubystyle.guide/
- Use meaningful variable and method names
- Add comments for complex logic
- Keep methods focused and small

## Testing

Before submitting:
- Run tests: `rspec`
- Check linter: `rubocop` (if configured)
- Test API endpoints manually

## Pull Request Process

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Commit with clear messages
4. Push to your fork
5. Create a Pull Request
6. Describe your changes clearly

## Reporting Issues

When reporting issues, please include:
- Description of the issue
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (Rails version, Ruby version, etc.)

## Feature Requests

For feature requests:
- Describe the feature clearly
- Explain the use case
- Suggest implementation approach if possible


