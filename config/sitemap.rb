# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://' + Settings.site_domain

SitemapGenerator::Sitemap.create(compress: false) do
  add meta_frames_search_path, priority: 1.0, changefreq: 'daily'
  Settings.example_words.each do |example_word|
    add meta_frames_example_path(example_word), priority: 0.8, changefreq: 'daily'
  end
  MetaFrame.includes(movie: { season: :siry }).all.each do |meta_frame|
    add(meta_frame_path(meta_frame), priority: 0.1, changefreq: 'weekly',images: [{
          loc: meta_frame.image_url,
          caption: meta_frame.description_text
        }])
  end
end
