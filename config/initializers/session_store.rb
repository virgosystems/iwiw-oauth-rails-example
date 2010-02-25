# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_iwiw-oauth-rails-example_session',
  :secret      => 'c247a14f095f342f5c43653b16d88cdb0eabd46f6986f35dfbe14d84365f2c03663e574b75c4c2a4d7293ad8f626d3afaf73575ac10dca1028a95de9efed69a7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
