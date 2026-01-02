# GEMINI.md

## Directory Overview

This directory contains a Ruby on Rails 8 application. It is set up with a modern frontend stack utilizing Hotwire (Turbo and Stimulus), React, esbuild for JavaScript bundling, and Tailwind CSS for styling. The application uses PostgreSQL as its database, Puma as the web server, and Sidekiq for background job processing. Deployment is configured using Kamal for Docker-based orchestration.

## Key Files

*   `Gemfile`: Manages Ruby gem dependencies, including Rails, Hotwire, Sidekiq, and Kamal.
*   `package.json`: Manages JavaScript dependencies, including React, Stimulus, Turbo, Tailwind CSS, and esbuild.
*   `config/routes.rb`: Defines the URL routes and their mapping to controller actions within the Rails application.
*   `app/`: The main directory for application source code, including models, views, controllers, helpers, and JavaScript components.
*   `Dockerfile`: Specifies the environment and instructions for building a Docker image of the application.
*   `.kamal/`: Contains configuration files and hooks for Kamal, the Docker-based deployment tool.

## Usage

This project is a standard Ruby on Rails web application. Developers can run it locally using standard Rails development commands (e.g., `bin/dev` or `rails server`). For deployment, the Kamal tool is used to build and orchestrate Docker containers on a production server. Frontend assets are managed with esbuild and Tailwind CSS, and JavaScript interactions are handled by a combination of Hotwire (Turbo and Stimulus) and React components.
