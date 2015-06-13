Rails.application.routes.draw do
  root 'home#index'

  resources 'workspaces', path: 's', format: false do
    resources 'sequences', param: :name,
                           format: false,
                           constraints: { name: %r{[^\/]+} }
  end

  devise_for :users, path: 'u', format: false
end
