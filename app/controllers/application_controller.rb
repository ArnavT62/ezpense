class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_controller

  before_action :authenticate_user!, unless: :devise_controller?

  private

  def layout_by_controller
    devise_controller? ? "devise" : "application"
  end
end
