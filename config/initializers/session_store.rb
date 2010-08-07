# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_collab_session',
  :secret      => 'fd983c9b7c9f6f8e44ce24fe536befedcd426cdb53d6b67e19cc750ed37721d1e07eb0d4583ee0404b4ec48fc9c289f55632fe7b0af23c44310cca0a85f8494c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
