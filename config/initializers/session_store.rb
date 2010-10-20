# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_twitter-oauth-guide_session',
  :secret      => 'c3665d6076e2c8af404b93a0875933edbc458c163aa7ed1351597caa3d9914874b9d4b3435a44d1d12cf6921e14b7ba61a750f23a7c7b4194390ddc6805ea063'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
