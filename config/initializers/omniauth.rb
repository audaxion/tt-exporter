Rails.application.config.middleware.use OmniAuth::Builder do
  provider :soundcloud, ENV['SC_APP_ID'], ENV['SC_APP_SECRET'], :scope => 'non-expiring'
end