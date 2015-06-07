Rails.application.routes.draw do
  devise_for :users, path: 'u'

  get 'home/index'
  resources 'workspaces', path: 's' do
    resources 'sequences'
  end
end
