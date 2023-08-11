Rails.application.routes.draw do
  root 'barbecues#index'

  resources :sessions, only: %i[new]

  scope '/oauth' do
    get 'authorize', to: 'oauth#authorize', as: 'oauth_authorize'
    get 'callback', to: 'oauth#callback', as: 'oauth_callback'
  end
end
