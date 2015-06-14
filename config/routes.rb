Rails.application.routes.draw do
  root 'home#index'

  resources 'workspaces', path: 'w', format: false do
    resources 'sequences', param: :name,
                           constraints: { name: %r{[^\/]+} } do
      get 'download/:format', action: 'download',
                              as: 'download'
    end
  end

  devise_for :users, path: 'u', format: false
end
