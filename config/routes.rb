Rails.application.routes.draw do
  root 'home#index'

  resources 'workspaces', path: 's' do
    resources 'sequences'
  end

  devise_for :users, path: 'u'
end
