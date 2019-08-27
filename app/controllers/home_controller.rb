class HomeController < ApplicationController
  def index
    if current_school.blank?
      render 'pupilfirst', layout: 'tailwind'
    elsif current_user.present?
      redirect_to after_sign_in_path_for(current_user)
    else
      redirect_to new_user_session_path
    end
  end

  def styleguide
    @skip_container = true
    @hide_layout_header = true
    render layout: 'tailwind'
  end

  # GET /policies/privacy
  def privacy
    @privacy_policy = if current_school.present?
      SchoolString::PrivacyPolicy.for(current_school)
    else
      File.read(Rails.root.join('privacy_policy.md'))
    end

    raise_not_found if @privacy_policy.blank?

    render layout: 'student'
  end

  # GET /policies/terms
  def terms
    @terms_of_use = if current_school.present?
      SchoolString::TermsOfUse.for(current_school)
    else
      File.read(Rails.root.join('terms_of_use.md'))
    end

    raise_not_found if @terms_of_use.blank?

    render layout: 'student'
  end

  # GET /oauth/:provider?fqdn=FQDN&referer=
  def oauth
    # Disallow routing OAuth results to unknown domains.
    raise_not_found if Domain.find_by(fqdn: params[:fqdn]).blank?

    set_cookie(:oauth_origin, {
      provider: params[:provider],
      fqdn: params[:fqdn],
      referer: params[:referer]
    }.to_json)

    redirect_to OmniauthProviderUrlService.new(params[:provider], current_host).oauth_url
  end

  # GET /oauth_error?error=
  def oauth_error
    flash[:notice] = params[:error]
    redirect_to new_user_session_path
  end

  # GET /favicon.ico
  def favicon
    if current_school.present? && current_school.icon.attached?
      redirect_to view_context.url_for(current_school.icon_variant(:thumb))
    else
      redirect_to '/favicon.png'
    end
  end

  protected

  def background_image_number
    @background_image_number ||= begin
      session[:background_image_number] ||= rand(1..4)
      session[:background_image_number] += 1
      session[:background_image_number] = 1 if session[:background_image_number] > 4
      session[:background_image_number]
    end
  end

  def hero_text_alignment
    @hero_text_alignment ||= begin
      {
        1 => 'center',
        2 => 'right',
        3 => 'right',
        4 => 'right'
      }[background_image_number]
    end
  end

  helper_method :background_image_number
  helper_method :hero_text_alignment
end
