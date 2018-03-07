class UsersController < ApplicationController

  before_action :ensure_user_profile_owner, only: [:edit, :update, :destroy]

  def index
    @users = User.where('kind = ?', 'musician')
    @users = if params[:term]
      User.where('first_name LIKE ? OR last_name LIKE ? OR stage_name LIKE ?', "%#{params[:term]}%", "%#{params[:term]}%", "%#{params[:term]}%")
    else
      User.where('kind = ?', 'musician')
    end
    if @users==[]
      flash.now[:alert] = "No search results found. Please try again."
    end
  end

  def show
    @user = User.find(params[:id])
    @review = Review.new
    if @user.kind == 'musician'
      @review = @user.musician_reviews.new
      @reviews = @user.musician_reviews
      @genres = @user.genres
      if current_user  # what if logged in as musician?, do we add && current_user.kind == 'client'?
        @review.client_id = current_user.id # not sure this line makes sense
        @pendingbookings = current_user.gigs.where('confirmed = ?', false)
        @confirmedbookings = current_user.gigs.where('confirmed = ? AND end_time > ?', true, Time.now)
        @pastbookings = current_user.gigs.where('confirmed = ? AND end_time < ?', true, Time.now)
      end
    elsif @user.kind == 'client'
      @review = @user.client_reviews.new
      @reviews = @user.client_reviews
      if current_user && current_user == @user
        @pendingbookings = current_user.events.where('confirmed = ?', false)
        @confirmedbookings = current_user.events.where('confirmed = ? AND end_time > ?', true, Time.now)
        @pastbookings = current_user.events.where('confirmed = ? AND end_time < ?', true, Time.now)
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.kind = params[:kind]

    if @user.save
      session[:user_id] = @user.id
      render "onboarding"
    else
      flash.now[:alert] = @user.errors.full_messages
      render "new"
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    if @user.act_type == nil
      @user.act_type = params[:act_type]
    end
    empty_profile_picture?
    if @user.save
      redirect_to user_url
    else
      flash.now[:alert] = @user.errors.full_messages
      render 'onboarding'
    end
  end

  def updatepassword
    @user = current_user
    render "updatepassword"
  end


  def destroy

  end

  def ensure_user_profile_owner
    @user = User.find(params[:id])
    if session[:user_id] != @user.id
      flash[:alert] = ["This is not your profile"]
      redirect_to users_url
    end
  end


  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :bio, :profile_picture, :stage_name, :hourly_rate, :address, genre_ids: [])
  end

  def empty_profile_picture?
    if @user.profile_picture == nil || @user.profile_picture == ""
      @user.update(profile_picture: "empty_profile.png")
    else
      @user.profile_picture
    end
  end

  def self.search(term)
    if term
      where("title ILIKE ?", "%#{term}%")
    else
      all
    end
  end


end
