# Override jsbundling-rails javascript:build task for Docker builds
# Assets are already built manually in Dockerfile, so skip rebuilding

if ENV['SKIP_YARN_BUILD'] == '1'
  Rake::Task['javascript:build'].clear if Rake::Task.task_defined?('javascript:build')

  namespace :javascript do
    desc 'Build JavaScript (skipped in Docker)'
    task build: :environment do
      puts 'Skipping javascript:build - assets already built'
    end
  end
end
