class UsersController < ApplicationController
  before_action :load_user, except: [:index, :create, :new]

  before_action :authorize_user, except: [:index, :create, :new, :show]

  def index
    @users = User.all
    @hashtags = Hashtag.with_questions
  end

  def new
    redirect_to root_path, alert: 'Вы уже залогинены' if current_user.present?
    @user = User.new
  end

  def create
    redirect_to root_path, alert: 'Вы уже залогинены' if current_user.present?

    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to user_path(@user), notice: 'Вы успешно залогинились!'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'Данные обновлены'
    else
      render 'edit'
    end
  end

  def show
    @questions = @user.questions.order(created_at: :desc)
    @new_question = @user.questions.build

    @number_questions = @user.questions.count
    @number_answer = @questions.where.not(answer: nil).count
    @unanswered = @number_questions - @number_answer
  end

  def destroy
    @user.destroy
    flash[:success] = "Пользователь удален"
    redirect_to users_path
  end

  private

  def authorize_user
    reject_user unless @user == current_user
  end

  def load_user
    @user ||= User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :name, :username, :avatar_url, :background)
  end
end
