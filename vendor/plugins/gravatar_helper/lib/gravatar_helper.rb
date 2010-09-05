require 'digest/md5'
require 'cgi'

module GravatarHelper

  def gravatar_url( email, options={} )
    options.reverse_merge(
      :default=>'/images/no-avatar.jpg',
      :size=>50,
      :rating=>'PG'
    )
    # Gravatar wants an MD5 hash of the email address...
    email_hash = Digest::MD5.hexdigest( email )
    default_image = CGI::escape( options[:default] )
    "http://www.gravatar.com/avatar.php?gravatar_id=#{email_hash}&size=#{options[:size]}&rating=#{options[:rating]}&default=#{options[:default_image]}"
  end

end
