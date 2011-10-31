require File.dirname(__FILE__)+'/abstract_unit'
require File.dirname(__FILE__)+'/fixtures/user'

class PasswordTest < Test::Unit::TestCase        
  fixtures :users
  
  def setup 
    super
    @user=User.new
  end             
  
  def test_mixin
    assert(@user.respond_to?(:password))
    assert(@user.respond_to?(:password_confirmation))
  end 
  
  def test_encrypt_password
    @user.password='password'
    @user.password_confirmation='password'
    assert_not_nil(@user.save)
    assert_equal(Digest::SHA1.hexdigest('password'), @user.password_hash)
  end
  
  def test_save_without_encrypt_password
    @user=User.find(1)
    @user.save
    assert_equal(Digest::SHA1.hexdigest('password'), @user.password_hash) 
  end       
  
  def test_password_confirmation
    @user.password='password'
    @user.password_confirmation='abcdefg'
    assert(! @user.valid?)
    assert_not_nil(@user.errors[:password])
  end
end
