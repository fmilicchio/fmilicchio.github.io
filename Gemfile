source "https://rubygems.org"

# Match GitHub Pages' pinned Jekyll/plugins set (reduces “works locally, fails on CI”).
gem "github-pages", "= 232", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-timeago", "~> 0.13.1"
end

# Windows + Ruby 3+ needs this for local serve sometimes
gem "webrick", "~> 1.7"

# Optional (Windows file watching). Add if you want the suggestion to go away:
# gem "wdm", ">= 0.1.0" if Gem.win_platform?
