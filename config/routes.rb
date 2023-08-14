Rails.application.routes.draw do
  root 'barbecues#index'

  get 'sessions/new', to: 'sessions#new', as: 'new_session'
  delete 'sessions/destroy', to: 'sessions#destroy', as: 'destroy_session'

  resources :barbecues, only: %i[index new create]

  post 'workspaces/select', to: 'workspaces#select', as: 'select_workspace'

  scope '/oauth' do
    get 'authorize', to: 'oauth#authorize', as: 'oauth_authorize'
    get 'callback', to: 'oauth#callback', as: 'oauth_callback'
  end

  namespace 'api' do
    resources :barbecues, only: %i[index create]
  end
end
