Project.configure do |project|
  project.build_command = <<-COMMAND.split("\n").map(&:strip).join(' ')
    sh -c "env RAILS_ENV=test bundle exec rspec"
  COMMAND
end

