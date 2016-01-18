# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_brunchen-finden_session',
  :secret      => '5d11a7055410499f8d8a8d0741420ff7df3be86d453b219db5ad5dfefbc64e5b1574f7d4aa461f6e8fc9b9243d5abb857d57a1b0455d9a2ed745bfafc139935f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
