require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase
  tests AccountMailer

  def setup
    @user = User.new(:full_name => "Tester", 
      :email => "tester@test.com",
      :password => "foobar")
  end

  test "welcome" do
    response = AccountMailer.create_welcome(@user)
    assert_equal("Welcome to taskfor.cc", response.subject)
    assert_equal('no-reply@taskfor.cc', response.from[0])
    assert_equal(@user.email, response.to[0])



#    @expected.subject = 'Welcome to taskfor.cc'
#    @expected.from       'no-reply@taskfor.cc'
#    @expected.body    = read_fixture('welcome')
#    @expected.date    = Time.now

#    assert_equal @expected.encoded, AccountMailer.create_welcome(@expected.date).encoded
  end

end
