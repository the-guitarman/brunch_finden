# After loading all rails, gem and plugin locales/languages
# load additional locales/languages to redefine former loaded translations and
# to add new.
# Note: I tryed to replace the star in "*.{rb,yml}" with the current local,
# to load the current locale/language only, but this won't work,
# if a switch to another locale is needed (there may be a fallback).
Dir[File.join(Rails.root.to_s, 'config', 'locales_additionals', "*.{rb,yml}")].each do |file|
  I18n.load_path << file
end


# Activate localisation fallback
# Note: This works with rails 2.3.8 or later only!
ver = Rails::VERSION
if ver::MAJOR >= 2 and ver::MINOR >= 3 and ver::TINY >= 8
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  fallbacks = [I18n.locale]
  fallbacks << :en unless I18n.locale.to_sym == :en
  I18n.fallbacks[I18n.locale] = fallbacks
end
