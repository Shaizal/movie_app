class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    @user = User.new(sign_up_params)

    session[:user_id] = @user.id
    session[:phone_number] = @user.phone_number

    send_otp

    redirect_to verify_otp_path
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number])
  end

  def send_otp
    otp_code = rand(100000..999999)

    client = Vonage::Client.new
    response = client.verify.request(
      number: @user.phone_number,
      brand: 'Your Brand Name',
      code_length: 6,
      lg: 'en-US'
    )

    if response.status == '0'
      session[:otp_code] = otp_code
      session[:request_id] = response.request_id
    else
      raise "Error sending OTP: #{response.status_message}"
    end
  end

  def verify_otp
    if params[:otp_code] == session[:otp_code]
      client = Vonage::Client.new
      response = client.verify.check(
        request_id: session[:request_id],
        code: params[:otp_code]
      )

      if response.status == '0'
        @user.save
        sign_in(@user)
        redirect_to root_path
      else
        flash[:error] = "Invalid OTP code"
        redirect_to verify_otp_path
      end
    else
      flash[:error] = "Invalid OTP code"
      redirect_to verify_otp_path
    end
  end
end
