# Security Guidelines

## Protecting Secrets

This project contains sensitive information that must never be committed to version control.

## Files That Must Never Be Committed

### Environment Variables
- `.env` - Local environment variables
- `.env.local` - Local overrides
- `.env.production` - Production secrets
- `.env.*` - Any environment-specific files
- **Always use `.env.example` as a template**

### Rails Secrets
- `/config/master.key` - Master encryption key
- `/config/credentials/*.key` - Credential keys
- `/config/credentials.yml.enc` - Encrypted credentials (if using Rails credentials)

### Database Configuration
- `config/database.yml.local` - Local database config with passwords
- Any database config files containing actual passwords

### API Keys and Tokens
- Files containing API keys
- Files containing authentication tokens
- Files with "secret", "password", "credential", "token", or "api_key" in the name

## Best Practices

### 1. Use Environment Variables
Store all secrets in environment variables, not in code:

```ruby
# Good
robot_endpoint = ENV['ROBOT_API_ENDPOINT']

# Bad
robot_endpoint = 'http://api.example.com/secret-key-12345'
```

### 2. Use Rails Credentials (Recommended)
For production secrets, use Rails encrypted credentials:

```bash
# Edit credentials
EDITOR="code --wait" rails credentials:edit

# Access in code
Rails.application.credentials.robot_api_endpoint
```

### 3. Never Commit Real Secrets
- Always use `.env.example` as a template
- Never commit actual `.env` files
- Use different secrets for development, staging, and production

### 4. Rotate Secrets Regularly
- Change API keys periodically
- Update database passwords regularly
- Rotate encryption keys when compromised

### 5. Use Different Secrets Per Environment
- Development: Use local/test secrets
- Staging: Use staging-specific secrets
- Production: Use production secrets (never commit!)

## Railway Deployment

When deploying to Railway:
1. Set all secrets in Railway dashboard → Variables
2. Never commit Railway tokens or API keys
3. Use Railway's built-in secret management

## If Secrets Are Accidentally Committed

If you accidentally commit secrets:

1. **Immediately rotate the secrets** - Change all exposed passwords/keys
2. **Remove from Git history**:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push** (coordinate with team first!)
4. **Notify team members** to update their local secrets

## Security Checklist

Before committing:
- [ ] No `.env` files in the commit
- [ ] No hardcoded passwords or API keys
- [ ] No database credentials in config files
- [ ] No master keys or credential keys
- [ ] `.env.example` is up to date (without real values)
- [ ] All secrets are in environment variables or Rails credentials

## Reporting Security Issues

If you discover a security vulnerability:
1. **DO NOT** create a public issue
2. Contact the project maintainers privately
3. Provide details of the vulnerability
4. Allow time for a fix before public disclosure

