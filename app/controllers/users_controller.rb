# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!

  def phone_number_form
    @user = current_user
  end

  def verify_phone_number
    @user = current_user

    if @user.update(user_params)
      send_otp
      redirect_to otp_verification_form_path
    else
      render :phone_number_form
    end
  end

  def otp_verification_form

  end


  def verify_otp
    Rails.logger.info "Submitted OTP: #{params[:otp_code]}"
    client = Vonage::Client.new
    response = client.verify.check(
      request_id: session[:request_id],
      code: params[:otp_code]
    )

    if response.status == '0'
      current_user.update(phone_number_verified: true)
      redirect_to root_path, notice: 'Phone number verified successfully!'
    else
      flash[:error] = "Invalid OTP code"
      redirect_to otp_verification_form_path
    end
  rescue Vonage::Error => e
    Rails.logger.error "Vonage Service Error: #{e.message}"
    flash[:error] = "An error occurred. Please try again."
    redirect_to otp_verification_form_path
  end



  private

  def user_params
    params.require(:user).permit(:phone_number)
  end

  def send_otp
    client = Vonage::Client.new
    response = client.verify.request(
      number: current_user.phone_number,
      brand: 'Your Brand Name',
      code_length: 6,
      lg: 'en-US'
    )

    if response.status == '0'
      session[:request_id] = response.request_id
    else
      raise "Error sending OTP: #{response.status_message}"
    end
  end
end
