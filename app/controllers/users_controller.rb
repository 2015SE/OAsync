class UsersController < ApplicationController
  include SessionsHelper
  include UsersHelper
  before_action :set_user, except: [:index,:new]
  before_action :logged_in, only: [:show]
  before_action :admin_logged_in, except: [:show]
  before_action :correct_user, only: :show

  def new
    @user=User.new
  end

  def create
    @user=User.new(user_params)
    if @user.save
      @user.create_salary
      @user.create_performance
      redirect_to users_path, flash: {success: "添加成功"}
    else
      flash[:warning] = "账号信息填写有误,请重试"
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to users_path, flash: flash
  end

  def destroy
    @user.destroy
    redirect_to users_path(new: false), flash: {success: "用户删除"}
  end

  def index
    @users=User.search(params).paginate(:page => params[:page], :per_page => 10)
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :sex, :department_id, :password,
                                 :phonenumber, :status)
  end

# Confirms a logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def admin_logged_in
    if logged_in? and current_user.role==5
    else
      redirect_to root_url, flash: {:danger => '您没有这个权限'}
    end
  end

  def correct_user
    unless current_user == @user or current_user.role == 5
      redirect_to user_path(current_user), flash: {:danger => '您没有权限浏览他人信息'}
    end
  end

  def set_user
    @user=User.find_by_id(params[:id])
    if @user.nil?
      redirect_to root_patht, flash: {:danger => '没有找到此用户'}
    end
  end

end
