require "test_helper"

class UsersProcessorTest < ActiveSupport::TestCase
  def user_to_params(user)
    {
      username: user.username,
      email: user.email,
      fullname: user.fullname,
      flag: user.flag,
      role: user.role,
      limit: user.limit,
      auth_network: user.auth_network&.identifier,
      networks: user.use_assignments.includes(:network)
        .map { |assignment| assignment.use_flag + assignment.network.identifier },
    }
  end

  setup do
    @user = users(:user)
    @processor = UsersProcessor.new(@user)
  end

  test "serialize user" do
    assert_equal user_to_params(@user), @processor.serialize(@user)
  end

  test "idx" do
    ids = @processor.ids

    assert_equal [@user.id], ids
  end

  # user

  test "index users" do
    users = @processor.index

    assert_equal [@user], users
  end

  test "show user" do
    assert_equal @user.fullname, @processor.show(@user.id)[:fullname]

    assert_raise Pundit::NotAuthorizedError do
      @processor.show(users(:admin).id)
    end
  end

  test "create user" do
    params = user_to_params(@user)
    assert_raise Pundit::NotAuthorizedError do
      @processor.create(params)
    end
  end

  test "update user" do
    params = user_to_params(@user)
    assert_raise Pundit::NotAuthorizedError do
      @processor.update(@user.id, params)
    end
  end

  test "desroy user" do
    assert_raise Pundit::NotAuthorizedError do
      @processor.destroy(@user.id)
    end
  end

  # admin

  test "admin: index users" do
    @processor = UsersProcessor.new(users(:admin))
    users = @processor.index

    assert_includes users, @user
  end

  test "admin: create user" do
    @processor = UsersProcessor.new(users(:admin))
    params = user_to_params(@user)
    assert_raise Pundit::NotAuthorizedError do
      @processor.create(params)
    end
  end

  test "admin: update user" do
    @processor = UsersProcessor.new(users(:admin))
    params = user_to_params(@user)
    # params[:name] = "Updated Name"
    # params[:place][:room] = "Updated Room"
    # params[:hardware][:product_name] = "Updated Product Name"
    # params[:operating_system][:name] = "Updated OS Name"
    assert_no_difference("User.count") do
      @processor.update(@user.id, params)
    end
    @user.reload
    # assert_equal "Updated Name", @user.name
    # assert_equal "Updated Room", @user.place.room
    # assert_equal "Updated Product Name", @user.hardware.product_name
    # assert_equal "Updated OS Name", @user.operating_system.name
  end

  test "admin: desroy user" do
    @processor = UsersProcessor.new(users(:admin))
    assert_raise Pundit::NotAuthorizedError do
      @processor.destroy(@user.id)
    end
  end
end
