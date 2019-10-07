Oaisys::Engine.routes.draw do
  resources :pmh, only: [:index]
  root to: "pmh#index"
end
