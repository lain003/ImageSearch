if ENV['IS_CIRCLECI']
  Settings.add_source!('config/settings/circleci.yml')
  Settings.reload!
end