require File.join(Rails.root,'lib','openshift_secret_generator.rb')
# Be sure to restart your server when you modify this file.

TurntableExporter::Application.config.session_store :cookie_store, key: initialize_secret(
    :session_store,
    '_turntable-exporter_session'
)
