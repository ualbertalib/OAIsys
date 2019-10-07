Oaisys::Engine.routes.draw do
  match '/', to: 'pmh#endpoint', via: [:get, :post]
end
