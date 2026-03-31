Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses do
    post :mail_month_to_date, on: :collection
  end
  resources :filters, except: :show

  root "expenses#index"
end
