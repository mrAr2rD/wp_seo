# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SEOforge** is a microSaaS platform for automating content creation and optimization for WordPress blogs. The application helps site owners, marketers, and bloggers manage content strategy, improve SEO, and automate article publishing.

### Core Product Vision
- Integrates with WordPress sites to analyze semantic keywords
- Generates SEO-optimized articles using LLMs (Gemini/OpenAI)
- Automates publishing to WordPress
- Provides analytics through Google Analytics and Search Console integration
- Subscription-based model using Stripe

## Technology Stack

### Backend
- **Rails 8.0** with PostgreSQL database
- **Sidekiq** for background job processing (configured as default queue adapter in [config/application.rb:26](config/application.rb#L26))
- **Solid Queue, Solid Cache, Solid Cable** for Rails infrastructure
- **Redis** for caching and Sidekiq
- **RSpec** for testing (configured in spec/)

### Frontend
- **React 19** with esbuild bundler
- **Hotwire** (Turbo Rails + Stimulus) for progressive enhancement
- **Tailwind CSS 3** for styling with PostCSS/Autoprefixer
- **Propshaft** for asset pipeline

### Infrastructure
- **Kamal** for Docker-based deployment
- **Puma** web server
- **Thruster** for HTTP asset caching

## Development Commands

### Starting the Application
```bash
bin/dev
```
This runs Foreman with [Procfile.dev](Procfile.dev), which starts:
- Rails server (port 3000 by default, with Ruby debug enabled)
- JavaScript build watcher (`yarn build --watch`)
- CSS build watcher (`yarn build:css --watch`)

### Building Assets
```bash
# Build JavaScript (React/Stimulus)
yarn build

# Build CSS (Tailwind)
yarn build:css

# Watch mode (both commands above with --watch)
```

### Database
```bash
# Standard Rails commands
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails db:rollback
```

### Testing with RSpec
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/file_spec.rb

# Run specific test by line number
bundle exec rspec spec/path/to/file_spec.rb:42
```

### Code Quality
```bash
# Lint Ruby code
bundle exec rubocop

# Security analysis
bundle exec brakeman
```

### Background Jobs
```bash
# Sidekiq is configured as the default Active Job adapter
# Start Sidekiq (if not using bin/dev)
bundle exec sidekiq
```

## Architecture

### Hybrid Frontend Approach
The application uses a **dual frontend strategy**:

1. **Hotwire (Turbo + Stimulus)** for progressive enhancement and server-rendered interactions
2. **React** for complex, stateful UI components that need rich interactivity

React is mounted on DOM elements with `id="react-app"` via [app/javascript/application.jsx](app/javascript/application.jsx). The main React entry point is [app/javascript/components/App.js](app/javascript/components/App.js).

### Asset Pipeline
- **JavaScript**: Bundled with esbuild, configured in [package.json](package.json#L11) scripts
- **CSS**: Tailwind CSS processed through PostCSS, watching files in app/views, app/helpers, app/assets/stylesheets, and app/javascript
- **Output**: Built assets go to `app/assets/builds/`

### Background Processing
Active Job is configured to use Sidekiq ([config/application.rb:26](config/application.rb#L26)). Key use cases:
- SEO keyword analysis and clustering
- Article generation via LLM APIs
- WordPress article publishing
- Google Analytics/Search Console data collection

### Module Name
The Rails application module is `Seoforge` ([config/application.rb:9](config/application.rb#L9)).

## Product Development Roadmap

The project follows a phased development approach (see [docs/ROADMAP.md](docs/ROADMAP.md)):

1. **Phase 1 (Complete)**: Project initialization - Rails 8, PostgreSQL, Sidekiq, RSpec, React with esbuild
2. **Phase 2 (Next)**: Backend MVP - User authentication (Devise), WordPress project management, Stripe subscription integration, basic admin panel
3. **Phase 3**: API documentation with OpenAPI/Swagger (Rswag)
4. **Phase 4**: Frontend MVP - Authentication UI, project dashboard, subscription management with Stripe Elements
5. **Phase 5**: AI/LLM integration - Keyword analysis, article generation, WordPress publishing, Google services OAuth
6. **Phase 6**: Advanced frontend - Content generation UI, WYSIWYG editor, analytics dashboard
7. **Phase 7**: Production deployment with CI/CD

## Key Product Features

### User Management
- Email/password authentication
- Profile management
- Password recovery

### Project Management
- Connect WordPress sites via API keys
- Validate WordPress REST API connections
- Manage multiple projects per user

### Content Generation
- Input article topics/ideas
- AI-powered keyword analysis and clustering (SEMrush/Ahrefs integration or custom parser)
- LLM-based article generation with proper HTML structure (H1/H2/H3)
- SEO optimization: title, description, alt tags
- WYSIWYG editor for review/editing
- One-click WordPress publishing (draft or published status)
- Category and tag management

### Analytics
- Google OAuth integration
- Google Analytics (GA4) metrics
- Google Search Console data (rankings, CTR, indexed pages)
- Project-specific and global dashboards

### Subscription Tiers
- **Free/Trial**: Limited articles and projects
- **Pro**: Expanded limits
- **Business**: Maximum limits, priority support

### Admin Panel
- User management
- Subscription oversight
- Service statistics

## Design Philosophy

Target UI/UX style: **Notion-like** - clean, minimalist, intuitive interface using **Shadcn UI** component library (or React equivalent).

## Security Considerations

- Encrypt and securely store WordPress API keys and OAuth tokens
- Standard Rails protections against XSS, CSRF, SQL injection
- Use Rails credentials for secrets management
