Rails.application.routes.draw do
  root 'welcome#index'

  resources 'workspaces', path: 'w', format: false do
    resources 'sequences', param: :name,
                           constraints: { name: %r{[^\/]+} } do
      get 'download/:format', action: 'download',
                              as: 'download'
    end
    resources 'namespaces', except: [:new, :edit]
  end

  devise_for :users, path: 'u', format: false
end
