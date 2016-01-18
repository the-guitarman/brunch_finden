#encoding: utf-8
require 'test_helper'

class BackendUserTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name).with_message(/is required/)
  should validate_presence_of(:name).with_message(/is required/)
  should validate_presence_of(:gender).with_message(/is required/)
  should validate_presence_of(:country).with_message(/is required/)
  should validate_presence_of(:user_group).with_message(/is required/)
  should validate_presence_of(:salary_type).with_message(/is required/)
  should validate_presence_of(:user_roles).with_message(/is required/)

  test "create backend user" do
    backend_user = BackendUser.first
    assert backend_user.valid?
  end

  test "user roles as in Mixins::HasUserRoles" do
    BackendUser.included_modules.include?(Mixins::HasUserRoles)
    backend_user = BackendUser.first
    assert_equal ["administrator"], backend_user.roles 
    backend_user.roles = ['administrator','manager']
    assert backend_user.is?('administrator')
    assert (not backend_user.is?('manager'))
    backend_user.roles = ['administrator','management']
    assert backend_user.is?('administrator')
    assert backend_user.is?('management')
    assert_equal 2, backend_user.roles.length
  end
end
