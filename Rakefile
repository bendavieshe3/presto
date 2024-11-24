# frozen_string_literal: true
# FILE: Rakefile

require 'rspec/core/rake_task'

GEMS = [
  'presto-core',
  'presto-cli'
].freeze

namespace :gems do
  desc 'Build all gems in correct order'
  task :build do
    GEMS.each do |gem|
      puts "\n=== Building #{gem} ==="
      Dir.chdir("gems/#{gem}") do
        sh 'bundle exec rake build'
      end
    end
  end

  desc 'Clean all built gem packages'
  task :clean do
    GEMS.each do |gem|
      puts "\n=== Cleaning #{gem} packages ==="
      Dir.chdir("gems/#{gem}") do
        sh 'rm -rf pkg'
      end
    end
  end

  desc 'Install all gems in correct order'
  task :install => :build do
    GEMS.each do |gem|
      puts "\n=== Installing #{gem} ==="
      Dir.chdir("gems/#{gem}") do
        latest_gem = Dir.glob('pkg/*.gem').max_by { |f| File.mtime(f) }
        sh "gem install #{latest_gem}"
      end
    end
  end

  desc 'Run all gem specs'
  task :spec do
    GEMS.each do |gem|
      puts "\n=== Running specs for #{gem} ==="
      Dir.chdir("gems/#{gem}") do
        sh 'bundle exec rspec'
      end
    end
  end

  desc 'Run all gem specs with documentation'
  task :spec_doc do
    GEMS.each do |gem|
      puts "\n=== Running documented specs for #{gem} ==="
      Dir.chdir("gems/#{gem}") do
        sh 'bundle exec rspec --format documentation'
      end
    end
  end

  namespace :dev do
    desc 'Setup development environment (bundle install for all gems)'
    task :setup do
      GEMS.each do |gem|
        puts "\n=== Setting up #{gem} ==="
        Dir.chdir("gems/#{gem}") do
          sh 'bundle install'
        end
      end
    end

    desc 'Update all gem dependencies'
    task :update do
      GEMS.each do |gem|
        puts "\n=== Updating #{gem} dependencies ==="
        Dir.chdir("gems/#{gem}") do
          sh 'bundle update'
        end
      end
    end
  end
end

# Convenience tasks at root level
desc 'Build and install all gems'
task :install => 'gems:install'

desc 'Run all specs'
task :spec => 'gems:spec'

desc 'Setup development environment'
task :setup => 'gems:dev:setup'

# Make spec the default task
task :default => :spec