namespace :elastic_seed do
  task run: :environment do
    MetaFrame.__elasticsearch__.create_index! force: true
    MetaFrame.__elasticsearch__.refresh_index!
    MetaFrame.import
  end
end
