class PMHConstraint
  PMHVERBS = %w(Identify ListSets ListMetadataFormats ListRecords GetRecord ListIdentifiers).freeze

  def matches?(request)
    request.query_parameters.key?(:verb) && PMHVERBS.include?(request.query_parameters[:verb])
  end
end

Oaisys::Engine.routes.draw do
  match '/', to: 'pmh#endpoint', via: [:get, :post], constraints: PMHConstraint.new
end
